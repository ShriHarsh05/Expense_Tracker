import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:expensetracker/controller/theme_controller.dart';
import 'package:expensetracker/services/auth_service.dart'; // Import your AuthService

class AppConstants {
  static const String usersCollection = 'users';
  static const String accentColorField = 'accentColor';
  static const double screenPadding = 16.0;
  static const double colorSwatchSpacing = 10.0;
  static const double colorSwatchRadius = 24.0;
}

class SettingsScreen extends StatefulWidget {
  final Function(Color) onColorChanged;

  const SettingsScreen({super.key, required this.onColorChanged});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  Color? _selectedColor;
  bool _isLoadingColor = true; // Added loading state

  final List<Color> _availableColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
  ];

  @override
  void initState() {
    super.initState();
    // Initialize _selectedColor with the current app theme color from ThemeController
    _selectedColor = ThemeController.accentColorNotifier.value;
    _loadSelectedColor();
  }

  Future<void> _loadSelectedColor() async {
    setState(() {
      _isLoadingColor = true; // Set loading to true
    });
    final user = AuthService.currentUser; // Use AuthService to get current user
    if (user != null) {
      try {
        final doc = await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .get();

        if (doc.exists &&
            doc.data() != null &&
            doc.data()!.containsKey(AppConstants.accentColorField)) {
          final colorValue = doc[AppConstants.accentColorField];
          final color = Color(colorValue);
          // Only update local state if mounted
          if (mounted) {
            setState(() {
              _selectedColor = color;
            });
            // Immediately apply the loaded color via the callback and ThemeController
            widget.onColorChanged(color);
            ThemeController.updateAccentColor(
                color); // Use the new update method
          }
        } else {
          // If no custom color found, ensure current theme controller value is used
          // (which would be default or previously set)
          if (mounted) {
            setState(() {
              _selectedColor = ThemeController.accentColorNotifier.value;
            });
          }
        }
      } on FirebaseException catch (e) {
        debugPrint('Firestore load color error: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to load theme color: ${e.message}'),
            ),
          );
        }
      } catch (e) {
        debugPrint('Unexpected error loading color: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
            ),
          );
        }
      }
    } else {
      // If no user is logged in, use the default theme controller color
      if (mounted) {
        setState(() {
          _selectedColor = ThemeController.accentColorNotifier.value;
        });
      }
    }
    if (mounted) {
      setState(() {
        _isLoadingColor = false; // Set loading to false
      });
    }
  }

  Future<void> _saveColorToCloud(Color color) async {
    final user = AuthService.currentUser; // Use AuthService
    if (user != null) {
      try {
        await FirebaseFirestore.instance
            .collection(AppConstants.usersCollection)
            .doc(user.uid)
            .set({
          AppConstants.accentColorField: color.value,
        }, SetOptions(merge: true));
        // Immediately apply the selected color
        widget.onColorChanged(color);
        ThemeController.updateAccentColor(color); // Use the new update method

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Accent color saved!'),
            ),
          );
        }
      } on FirebaseException catch (e) {
        debugPrint('Firestore save color error: ${e.message}');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Failed to save color: ${e.message}'),
            ),
          );
        }
      } catch (e) {
        debugPrint('Unexpected error saving color: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('An unexpected error occurred: $e'),
            ),
          );
        }
      }
    } else {
      // If user is not logged in, just apply locally and show info
      if (mounted) {
        widget.onColorChanged(color);
        ThemeController.updateAccentColor(color);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content:
                Text('Color applied locally. Sign in to save permanently!'),
          ),
        );
      }
    }
  }

  Future<void> _signOut() async {
    final bool confirm = await showDialog(
          context: context,
          builder: (ctx) => AlertDialog(
            title: const Text('Confirm Sign Out'),
            content: const Text('Are you sure you want to sign out?'),
            actions: [
              TextButton(
                onPressed: () {
                  Navigator.of(ctx).pop(false);
                },
                child: const Text('Cancel'),
              ),
              FilledButton(
                onPressed: () {
                  Navigator.of(ctx).pop(true);
                },
                child: const Text('Sign Out'),
              ),
            ],
          ),
        ) ??
        false; // In case dialog is dismissed by tapping outside

    if (confirm) {
      try {
        await AuthService.signOut(); // <--- Use AuthService here!
        if (!mounted) return;
        // Navigation to LoginScreen is now handled by main.dart's StreamBuilder.
        // Just pop the current settings screen if it's a modal bottom sheet.
        // If it's a full screen, then no navigation needed here either.
        if (Navigator.of(context).canPop()) {
          // Check if it's a modal or has parent route
          Navigator.of(context).pop(); // Close the settings sheet/screen
        }
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('You have been signed out.'),
          ),
        );
      } on Exception catch (e) {
        // Catching general Exception because AuthService rethrows both Firebase & general errors
        debugPrint('Sign out error: $e');
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Sign out failed: ${e.toString()}'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: ListView(
            padding: const EdgeInsets.all(AppConstants.screenPadding),
            children: [
              // --- Theme Color Section ---
              const Text(
                'App Theme Color', // More general title
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.screenPadding),
              _isLoadingColor
                  ? const Center(child: CircularProgressIndicator())
                  : Wrap(
                      spacing: AppConstants.colorSwatchSpacing,
                      runSpacing: AppConstants
                          .colorSwatchSpacing, // For better wrapping
                      children: _availableColors.map((color) {
                        // Ensure _selectedColor is initialized, default to current theme if not loaded
                        final currentSelectedColor = _selectedColor ??
                            ThemeController.accentColorNotifier.value;
                        final isSelected = currentSelectedColor.value ==
                            color.value; // Compare value for exact match
                        return GestureDetector(
                          onTap: () {
                            setState(() {
                              _selectedColor = color;
                            });
                            _saveColorToCloud(color); // Save and apply
                          },
                          child: Container(
                            // Using Container for border
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              border: isSelected
                                  ? Border.all(
                                      color: Theme.of(context)
                                          .colorScheme
                                          .primary, // Use primary color for border
                                      width: 3,
                                    )
                                  : null,
                            ),
                            child: CircleAvatar(
                              radius: AppConstants.colorSwatchRadius,
                              backgroundColor: color,
                              child: isSelected
                                  ? const Icon(Icons.check, color: Colors.white)
                                  : null,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
              const Divider(height: 40), // Visual divider

              // --- Account Section ---
              const Text(
                'Account Actions', // New section for account actions
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: AppConstants.screenPadding),
              // Sign Out Button
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: _signOut,
                  label: const Text('Sign Out'),
                  icon: const Icon(Icons.logout),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.error,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
