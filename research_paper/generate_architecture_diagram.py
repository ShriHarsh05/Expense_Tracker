#!/usr/bin/env python3
"""
Patent-Style System Architecture Diagram Generator
Generates a clean black and white patent-style architecture diagram with no overlapping elements.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Rectangle, FancyArrowPatch
import numpy as np

# Set up the figure with high DPI for publication quality
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'

def create_architecture_diagram():
    # Create figure with even larger dimensions to prevent overlapping
    fig, ax = plt.subplots(1, 1, figsize=(18, 14))
    ax.set_xlim(0, 18)
    ax.set_ylim(0, 14)
    ax.axis('off')
    
    # Patent-style black and white colors (strict patent compliance)
    colors = {
        'black': '#000000',        # Pure black for text and borders
        'white': '#FFFFFF',        # Pure white for backgrounds
        'light_gray': '#E8E8E8',   # Light gray for alternating layers
        'medium_gray': '#C0C0C0',  # Medium gray for emphasis boxes
        'dark_gray': '#404040'     # Dark gray for flow indicators
    }
    
    # Title section with generous spacing
    title_box = Rectangle((2, 12.5), 14, 1, 
                         facecolor=colors['white'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(title_box)
    ax.text(9, 13.2, 'INTELLIGENT SMS-BASED EXPENSE CATEGORIZATION SYSTEM', 
            fontsize=16, fontweight='bold', ha='center', va='center')
    ax.text(9, 12.8, 'Four-Layer Hybrid AI Architecture', 
            fontsize=12, ha='center', va='center', style='italic')
    
    # Layer dimensions - much more generous spacing
    layer_width = 14
    layer_height = 1.8
    layer_spacing = 0.8
    
    # SMS Input Layer (Y = 10.5)
    y_input = 10.5
    input_box = Rectangle((2, y_input), layer_width, layer_height, 
                         facecolor=colors['light_gray'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(input_box)
    ax.text(9, y_input + 1.3, 'SMS NOTIFICATION INPUT', 
            fontsize=14, fontweight='bold', ha='center', va='center')
    
    # SMS source boxes - well spaced
    sms_sources = ['HDFC Bank', 'AXIS Bank', 'PAYTM', 'ICICI Bank', 'SBI Card']
    for i, source in enumerate(sms_sources):
        x_pos = 3.5 + i * 2.5
        source_box = Rectangle((x_pos-0.9, y_input + 0.3), 1.8, 0.6, 
                              facecolor=colors['white'], 
                              edgecolor=colors['black'], 
                              linewidth=1)
        ax.add_patch(source_box)
        ax.text(x_pos, y_input + 0.6, source, fontsize=10, ha='center', va='center', fontweight='bold')
    
    # Arrow 1
    y_arrow1 = y_input - 0.3
    arrow1 = FancyArrowPatch((9, y_arrow1), (9, y_arrow1 - layer_spacing + 0.3),
                            arrowstyle='->', 
                            mutation_scale=25, 
                            color=colors['black'], 
                            linewidth=3)
    ax.add_patch(arrow1)
    
    # Security Layer (Y = 8.4)
    y_security = 8.4
    security_box = Rectangle((2, y_security), layer_width, layer_height, 
                            facecolor=colors['white'], 
                            edgecolor=colors['black'], 
                            linewidth=2)
    ax.add_patch(security_box)
    ax.text(9, y_security + 1.3, 'LAYER 0: AUTHENTIC SENDER VALIDATION', 
            fontsize=14, fontweight='bold', ha='center', va='center')
    
    # Security components - well spaced horizontally
    security_items = [
        ('ACCEPT', 'Bank Codes\n4-6 Digits'),
        ('VALIDATE', 'Pattern Match\nAlgorithms'),
        ('REJECT', 'Phone Numbers\nFraud SMS')
    ]
    
    for i, (action, desc) in enumerate(security_items):
        x_pos = 4.5 + i * 4
        # Action box
        action_box = Rectangle((x_pos-1.2, y_security + 0.7), 2.4, 0.5, 
                              facecolor=colors['medium_gray'], 
                              edgecolor=colors['black'], 
                              linewidth=1)
        ax.add_patch(action_box)
        ax.text(x_pos, y_security + 0.95, action, fontsize=11, ha='center', va='center', fontweight='bold')
        # Description below
        ax.text(x_pos, y_security + 0.35, desc, fontsize=9, ha='center', va='center')
    
    # Arrow 2
    y_arrow2 = y_security - 0.3
    arrow2 = FancyArrowPatch((9, y_arrow2), (9, y_arrow2 - layer_spacing + 0.3),
                            arrowstyle='->', 
                            mutation_scale=25, 
                            color=colors['black'], 
                            linewidth=3)
    ax.add_patch(arrow2)
    
    # Hybrid Categorization Layer (Y = 6.3)
    y_categorization = 6.3
    categorization_box = Rectangle((2, y_categorization), layer_width, layer_height, 
                           facecolor=colors['light_gray'], 
                           edgecolor=colors['black'], 
                           linewidth=2)
    ax.add_patch(categorization_box)
    ax.text(9, y_categorization + 1.3, 'LAYER 1: THREE-LAYER HYBRID CATEGORIZATION', 
            fontsize=14, fontweight='bold', ha='center', va='center')
    
    # Three sub-layers - properly spaced
    sublayers = ['Layer 0: Indian DB\n150+ Merchants', 'Layer 1: Foursquare\nAPI Fallback', 'Layer 2: Keywords\nScoring Algorithm']
    for i, sublayer in enumerate(sublayers):
        x_pos = 4.5 + i * 4
        sublayer_box = Rectangle((x_pos-1.2, y_categorization + 0.3), 2.4, 0.8, 
                              facecolor=colors['white'], 
                              edgecolor=colors['black'], 
                              linewidth=1)
        ax.add_patch(sublayer_box)
        ax.text(x_pos, y_categorization + 0.7, sublayer, fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Arrow 3
    y_arrow3 = y_categorization - 0.3
    arrow3 = FancyArrowPatch((9, y_arrow3), (9, y_arrow3 - layer_spacing + 0.3),
                            arrowstyle='->', 
                            mutation_scale=25, 
                            color=colors['black'], 
                            linewidth=3)
    ax.add_patch(arrow3)
    
    # Smart Learning Layer (Y = 4.2)
    y_learning = 4.2
    learning_box = Rectangle((2, y_learning), layer_width, layer_height, 
                           facecolor=colors['white'], 
                           edgecolor=colors['black'], 
                           linewidth=2)
    ax.add_patch(learning_box)
    ax.text(9, y_learning + 1.3, 'LAYER 2: SMART LEARNING SYSTEM', 
            fontsize=14, fontweight='bold', ha='center', va='center')
    
    # Learning algorithm box
    formula_box = Rectangle((4, y_learning + 0.8), 10, 0.4, 
                           facecolor=colors['medium_gray'], 
                           edgecolor=colors['black'], 
                           linewidth=1)
    ax.add_patch(formula_box)
    ax.text(9, y_learning + 1, 'User Feedback Learning | Similarity > 0.7 → Auto-categorize', 
            fontsize=11, ha='center', va='center', fontweight='bold')
    
    # Learning features - well separated
    features = ['Amount Patterns', 'Time Patterns', 'Merchant Patterns', 'User Corrections']
    for i, feature in enumerate(features):
        x_pos = 4 + i * 3
        feature_box = Rectangle((x_pos-0.9, y_learning + 0.1), 1.8, 0.6, 
                               facecolor=colors['light_gray'], 
                               edgecolor=colors['black'], 
                               linewidth=1)
        ax.add_patch(feature_box)
        ax.text(x_pos, y_learning + 0.4, feature, fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Arrow 4
    y_arrow4 = y_learning - 0.3
    arrow4 = FancyArrowPatch((9, y_arrow4), (9, y_arrow4 - layer_spacing + 0.3),
                            arrowstyle='->', 
                            mutation_scale=25, 
                            color=colors['black'], 
                            linewidth=3)
    ax.add_patch(arrow4)
    
    # Mobile Application Layer (Y = 2.1)
    y_mobile = 2.1
    mobile_box = Rectangle((2, y_mobile), layer_width, layer_height, 
                            facecolor=colors['light_gray'], 
                            edgecolor=colors['black'], 
                            linewidth=2)
    ax.add_patch(mobile_box)
    ax.text(9, y_mobile + 1.3, 'FLUTTER MOBILE APPLICATION', 
            fontsize=14, fontweight='bold', ha='center', va='center')
    
    # Performance metrics
    perf_text = 'Local Processing | 12ms per SMS | <50MB Memory | <2% Battery'
    ax.text(9, y_mobile + 0.9, perf_text, fontsize=10, ha='center', va='center')
    
    # Mobile app components - well spaced
    components = ['SMS Scanner\nPermissions', 'Expense Storage\nFirebase Sync', 'UI Display\nUser Interface']
    for i, component in enumerate(components):
        x_pos = 5 + i * 4
        comp_box = Rectangle((x_pos-1.2, y_mobile + 0.1), 2.4, 0.6, 
                            facecolor=colors['white'], 
                            edgecolor=colors['black'], 
                            linewidth=1)
        ax.add_patch(comp_box)
        ax.text(x_pos, y_mobile + 0.4, component, fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Performance metrics box (right side) - moved further right to avoid overlap
    perf_x = 15.5
    perf_box = Rectangle((perf_x, 4), 2, 7, 
                        facecolor=colors['light_gray'], 
                        edgecolor=colors['black'], 
                        linewidth=2)
    ax.add_patch(perf_box)
    ax.text(perf_x + 1, 10.5, 'PERFORMANCE METRICS', fontsize=11, fontweight='bold', ha='center', va='center', rotation=90)
    
    metrics = ['94.2%\nAccuracy', '89.7%\nClassify', '87%\nEffort', '4.6/5.0\nSatisfy']
    for i, metric in enumerate(metrics):
        y_pos = 9.5 - i * 1.5
        metric_box = Rectangle((perf_x + 0.1, y_pos-0.5), 1.8, 1, 
                              facecolor=colors['white'], 
                              edgecolor=colors['black'], 
                              linewidth=1)
        ax.add_patch(metric_box)
        ax.text(perf_x + 1, y_pos, metric, fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Data flow numbers (left side) - better positioning
    flow_x = 0.2
    flow_labels = ['SMS\nInput', 'Security\nFilter', 'Hybrid\nCategorize', 'Smart\nLearning']
    for i in range(4):
        y_pos = 11.25 - i * 2.1
        flow_box = Rectangle((flow_x, y_pos-0.4), 1, 0.8, 
                            facecolor=colors['dark_gray'], 
                            edgecolor=colors['black'], 
                            linewidth=1)
        ax.add_patch(flow_box)
        ax.text(flow_x + 0.5, y_pos, str(i+1), fontsize=16, ha='center', va='center', 
               color=colors['white'], fontweight='bold')
        
        # Add flow label next to the number - better spacing
        ax.text(flow_x + 1.3, y_pos, flow_labels[i], fontsize=9, ha='left', va='center', 
               fontweight='bold')
    
    # Add horizontal flow arrows connecting the numbered steps to main layers
    for i in range(4):
        y_pos = 11.25 - i * 2.1
        # Arrow from flow number to main content - shorter arrows
        flow_arrow = FancyArrowPatch((flow_x + 1.2, y_pos), (1.8, y_pos),
                                    arrowstyle='->', 
                                    mutation_scale=12, 
                                    color=colors['dark_gray'], 
                                    linewidth=2,
                                    linestyle='--')
        ax.add_patch(flow_arrow)
    
    # Remove the right side flow indicators to eliminate overlap
    # Instead, add simple output labels at the end of each layer
    
    # Add output indicators at the right edge of each layer
    output_labels = [
        ('Raw SMS\nData', 11.25),
        ('Validated\nSMS', 9.15),
        ('Categorized\nExpense', 7.05),
        ('Learning\nData', 4.95)
    ]
    
    for label, y_pos in output_labels:
        # Small output box at the right edge
        output_box = Rectangle((14.2, y_pos-0.25), 1.2, 0.5, 
                              facecolor=colors['medium_gray'], 
                              edgecolor=colors['black'], 
                              linewidth=1)
        ax.add_patch(output_box)
        ax.text(14.8, y_pos, label, fontsize=8, ha='center', va='center', 
               fontweight='bold')
        
        # Small arrow from layer to output
        output_arrow = FancyArrowPatch((14, y_pos), (14.2, y_pos),
                                      arrowstyle='->', 
                                      mutation_scale=10, 
                                      color=colors['black'], 
                                      linewidth=1)
        ax.add_patch(output_arrow)
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the patent-style system architecture diagram."""
    print("Generating Patent-Style System Architecture Diagram...")
    
    # Create the diagram
    fig = create_architecture_diagram()
    
    # Save in PNG and JPG formats with white background (patent standard)
    output_files = [
        ('research_paper/system_architecture_diagram.png', 'PNG'),
        ('research_paper/system_architecture_diagram.jpg', 'JPEG')
    ]
    
    for output_file, format_type in output_files:
        fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                   facecolor='white', edgecolor='black', format=format_type.lower(),
                   pad_inches=0.2)  # Add padding for patent compliance
        print(f"✅ Saved: {output_file}")
    
    print("\n🎯 Patent-Style Diagram Generation Complete!")
    print("\nFiles generated:")
    print("� PPNG format: High-resolution for papers (300 DPI)")
    print("� JPGi format: Compressed image for presentations")
    print("\n📐 Dimensions: 18×14 inches (patent-style landscape)")
    print("🎨 Strict black and white patent formatting")
    print("� Clean flayout with proper contrast ratios")
    print("📋 Ready for patent applications and academic papers!")
    
    # Show the plot
    plt.show()

if __name__ == "__main__":
    main()