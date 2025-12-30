#!/usr/bin/env python3
"""
SMS Processing Pipeline Diagram Generator
Generates a detailed flowchart showing the SMS processing pipeline for expense categorization.
"""

import matplotlib.pyplot as plt
import matplotlib.patches as patches
from matplotlib.patches import Rectangle, FancyArrowPatch, Circle
import numpy as np

# Set up the figure with high DPI for publication quality
plt.rcParams['figure.dpi'] = 300
plt.rcParams['savefig.dpi'] = 300
plt.rcParams['font.family'] = 'Arial'

def create_sms_pipeline_diagram():
    # Create figure with flowchart dimensions
    fig, ax = plt.subplots(1, 1, figsize=(16, 20))
    ax.set_xlim(0, 16)
    ax.set_ylim(0, 20)
    ax.axis('off')
    
    # Colors for different types of processes
    colors = {
        'black': '#000000',
        'white': '#FFFFFF',
        'light_gray': '#F0F0F0',
        'medium_gray': '#D0D0D0',
        'dark_gray': '#606060',
        'decision': '#E8F4FD',  # Light blue for decision boxes
        'process': '#F0F8E8',   # Light green for process boxes
        'data': '#FFF8E1',      # Light yellow for data boxes
        'error': '#FFEBEE'      # Light red for error handling
    }
    
    # Title
    title_box = Rectangle((2, 19), 12, 0.8, 
                         facecolor=colors['white'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(title_box)
    ax.text(8, 19.4, 'SMS PROCESSING PIPELINE', 
            fontsize=16, fontweight='bold', ha='center', va='center')
    ax.text(8, 19.1, 'Intelligent Expense Detection and Categorization Flow', 
            fontsize=12, ha='center', va='center', style='italic')
    
    # Step 1: SMS Input
    step1_box = Rectangle((6, 17.5), 4, 1, 
                         facecolor=colors['data'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step1_box)
    ax.text(8, 18, 'SMS MESSAGE\nRECEIVED', 
            fontsize=11, fontweight='bold', ha='center', va='center')
    
    # Arrow 1
    arrow1 = FancyArrowPatch((8, 17.5), (8, 16.8),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow1)
    
    # Step 2: Permission Check
    step2_box = Rectangle((6, 16), 4, 0.8, 
                         facecolor=colors['decision'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step2_box)
    ax.text(8, 16.4, 'SMS PERMISSION\nGRANTED?', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Permission denied path
    denied_box = Rectangle((11, 15.8), 3, 1.2, 
                          facecolor=colors['error'], 
                          edgecolor=colors['black'], 
                          linewidth=1)
    ax.add_patch(denied_box)
    ax.text(12.5, 16.4, 'PERMISSION\nDENIED\nEXIT', 
            fontsize=9, ha='center', va='center')
    
    # Arrow to denied
    arrow_denied = FancyArrowPatch((10, 16.4), (11, 16.4),
                                  arrowstyle='->', 
                                  mutation_scale=15, 
                                  color=colors['black'], 
                                  linewidth=1)
    ax.add_patch(arrow_denied)
    ax.text(10.5, 16.7, 'NO', fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Arrow 2 (YES path)
    arrow2 = FancyArrowPatch((8, 16), (8, 15.3),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow2)
    ax.text(7.3, 15.6, 'YES', fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Step 3: Fetch Recent SMS
    step3_box = Rectangle((6, 14.5), 4, 0.8, 
                         facecolor=colors['process'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step3_box)
    ax.text(8, 14.9, 'FETCH LAST 50 SMS\n(LAST 7 DAYS)', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Arrow 3
    arrow3 = FancyArrowPatch((8, 14.5), (8, 13.8),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow3)
    
    # Step 4: Sender Validation
    step4_box = Rectangle((5.5, 13), 5, 0.8, 
                         facecolor=colors['decision'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step4_box)
    ax.text(8, 13.4, 'AUTHENTIC SENDER\nVALIDATION', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Sender validation details (left side)
    valid_box = Rectangle((1, 12.2), 3.5, 1.6, 
                         facecolor=colors['process'], 
                         edgecolor=colors['black'], 
                         linewidth=1)
    ax.add_patch(valid_box)
    ax.text(2.75, 13.5, 'ACCEPT:', fontsize=9, fontweight='bold', ha='center', va='center')
    ax.text(2.75, 13.2, '• Bank codes (HDFCBK)', fontsize=8, ha='center', va='center')
    ax.text(2.75, 13, '• Short codes (56767)', fontsize=8, ha='center', va='center')
    ax.text(2.75, 12.8, '• Wallet codes', fontsize=8, ha='center', va='center')
    ax.text(2.75, 12.6, '• Extended formats', fontsize=8, ha='center', va='center')
    ax.text(2.75, 12.4, '(VM-MOBIKW-*)', fontsize=8, ha='center', va='center')
    
    # Invalid sender path (right side)
    invalid_box = Rectangle((11.5, 12.2), 3.5, 1.6, 
                           facecolor=colors['error'], 
                           edgecolor=colors['black'], 
                           linewidth=1)
    ax.add_patch(invalid_box)
    ax.text(13.25, 13.5, 'REJECT:', fontsize=9, fontweight='bold', ha='center', va='center')
    ax.text(13.25, 13.2, '• Phone numbers', fontsize=8, ha='center', va='center')
    ax.text(13.25, 13, '• Fraud SMS', fontsize=8, ha='center', va='center')
    ax.text(13.25, 12.8, '• Invalid patterns', fontsize=8, ha='center', va='center')
    ax.text(13.25, 12.6, '• Personal senders', fontsize=8, ha='center', va='center')
    ax.text(13.25, 12.4, 'SKIP SMS', fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrows for validation
    arrow_valid = FancyArrowPatch((5.5, 13.4), (4.5, 13.4),
                                 arrowstyle='->', 
                                 mutation_scale=15, 
                                 color=colors['black'], 
                                 linewidth=1)
    ax.add_patch(arrow_valid)
    ax.text(5, 13.7, 'VALID', fontsize=8, ha='center', va='center', fontweight='bold')
    
    arrow_invalid = FancyArrowPatch((10.5, 13.4), (11.5, 13.4),
                                   arrowstyle='->', 
                                   mutation_scale=15, 
                                   color=colors['black'], 
                                   linewidth=1)
    ax.add_patch(arrow_invalid)
    ax.text(11, 13.7, 'INVALID', fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrow 4 (continue with valid SMS)
    arrow4 = FancyArrowPatch((8, 13), (8, 12.3),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow4)
    
    # Step 5: Expense Keywords Check
    step5_box = Rectangle((5.5, 11.5), 5, 0.8, 
                         facecolor=colors['decision'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step5_box)
    ax.text(8, 11.9, 'CONTAINS EXPENSE\nKEYWORDS?', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Keywords list (left side)
    keywords_box = Rectangle((1, 10.5), 4, 1.8, 
                            facecolor=colors['data'], 
                            edgecolor=colors['black'], 
                            linewidth=1)
    ax.add_patch(keywords_box)
    ax.text(3, 11.8, 'EXPENSE KEYWORDS:', fontsize=9, fontweight='bold', ha='center', va='center')
    ax.text(3, 11.5, '• debited, spent, charged', fontsize=8, ha='center', va='center')
    ax.text(3, 11.3, '• purchase, withdrawn', fontsize=8, ha='center', va='center')
    ax.text(3, 11.1, '• card no., credit card', fontsize=8, ha='center', va='center')
    ax.text(3, 10.9, '• avl limit, transaction', fontsize=8, ha='center', va='center')
    ax.text(3, 10.7, '• wallet balance debited', fontsize=8, ha='center', va='center')
    
    # No keywords path (right side)
    no_keywords_box = Rectangle((11.5, 11), 3.5, 0.8, 
                               facecolor=colors['error'], 
                               edgecolor=colors['black'], 
                               linewidth=1)
    ax.add_patch(no_keywords_box)
    ax.text(13.25, 11.4, 'NO EXPENSE\nKEYWORDS\nSKIP SMS', 
            fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Arrows for keywords
    arrow_keywords = FancyArrowPatch((5.5, 11.9), (5, 11.9),
                                    arrowstyle='->', 
                                    mutation_scale=15, 
                                    color=colors['black'], 
                                    linewidth=1)
    ax.add_patch(arrow_keywords)
    
    arrow_no_keywords = FancyArrowPatch((10.5, 11.9), (11.5, 11.4),
                                       arrowstyle='->', 
                                       mutation_scale=15, 
                                       color=colors['black'], 
                                       linewidth=1)
    ax.add_patch(arrow_no_keywords)
    ax.text(11, 12.1, 'NO', fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrow 5 (continue with expense SMS)
    arrow5 = FancyArrowPatch((8, 11.5), (8, 10.8),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow5)
    ax.text(7.3, 11.1, 'YES', fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Step 6: Amount Extraction
    step6_box = Rectangle((6, 10), 4, 0.8, 
                         facecolor=colors['process'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step6_box)
    ax.text(8, 10.4, 'EXTRACT AMOUNT\nUSING REGEX', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Arrow 6
    arrow6 = FancyArrowPatch((8, 10), (8, 9.3),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow6)
    
    # Step 7: Duplicate Check
    step7_box = Rectangle((5.5, 8.5), 5, 0.8, 
                         facecolor=colors['decision'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step7_box)
    ax.text(8, 8.9, 'DUPLICATE EXPENSE\nCHECK', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Duplicate found path
    duplicate_box = Rectangle((11.5, 8.3), 3.5, 0.8, 
                             facecolor=colors['error'], 
                             edgecolor=colors['black'], 
                             linewidth=1)
    ax.add_patch(duplicate_box)
    ax.text(13.25, 8.7, 'DUPLICATE FOUND\nSKIP SMS', 
            fontsize=9, ha='center', va='center', fontweight='bold')
    
    arrow_duplicate = FancyArrowPatch((10.5, 8.9), (11.5, 8.7),
                                     arrowstyle='->', 
                                     mutation_scale=15, 
                                     color=colors['black'], 
                                     linewidth=1)
    ax.add_patch(arrow_duplicate)
    ax.text(11, 9.1, 'YES', fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrow 7 (no duplicate)
    arrow7 = FancyArrowPatch((8, 8.5), (8, 7.8),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow7)
    ax.text(7.3, 8.1, 'NO', fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Step 8: Three-Layer Categorization
    step8_box = Rectangle((5, 7), 6, 0.8, 
                         facecolor=colors['process'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step8_box)
    ax.text(8, 7.4, 'THREE-LAYER HYBRID CATEGORIZATION', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Categorization layers (horizontal)
    cat_layers = ['Indian DB', 'Foursquare API', 'Keywords']
    for i, layer in enumerate(cat_layers):
        x_pos = 5.5 + i * 2
        layer_box = Rectangle((x_pos-0.6, 6.2), 1.2, 0.6, 
                             facecolor=colors['data'], 
                             edgecolor=colors['black'], 
                             linewidth=1)
        ax.add_patch(layer_box)
        ax.text(x_pos, 6.5, layer, fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrow 8
    arrow8 = FancyArrowPatch((8, 7), (8, 6.3),
                            arrowstyle='->', 
                            mutation_scale=20, 
                            color=colors['black'], 
                            linewidth=2)
    ax.add_patch(arrow8)
    
    # Step 9: Smart Learning Check
    step9_box = Rectangle((5.5, 5.5), 5, 0.8, 
                         facecolor=colors['decision'], 
                         edgecolor=colors['black'], 
                         linewidth=2)
    ax.add_patch(step9_box)
    ax.text(8, 5.9, 'SMART LEARNING\nSUGGESTION', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Learning paths
    auto_box = Rectangle((1, 4.7), 3.5, 1.6, 
                        facecolor=colors['process'], 
                        edgecolor=colors['black'], 
                        linewidth=1)
    ax.add_patch(auto_box)
    ax.text(2.75, 5.9, 'AUTO-CATEGORIZE', fontsize=9, fontweight='bold', ha='center', va='center')
    ax.text(2.75, 5.6, 'Similarity > 0.7', fontsize=8, ha='center', va='center')
    ax.text(2.75, 5.4, 'Based on:', fontsize=8, ha='center', va='center')
    ax.text(2.75, 5.2, '• Amount patterns', fontsize=8, ha='center', va='center')
    ax.text(2.75, 5, '• Time patterns', fontsize=8, ha='center', va='center')
    ax.text(2.75, 4.8, '• User history', fontsize=8, ha='center', va='center')
    
    prompt_box = Rectangle((11.5, 4.7), 3.5, 1.6, 
                          facecolor=colors['decision'], 
                          edgecolor=colors['black'], 
                          linewidth=1)
    ax.add_patch(prompt_box)
    ax.text(13.25, 5.9, 'PROMPT USER', fontsize=9, fontweight='bold', ha='center', va='center')
    ax.text(13.25, 5.6, 'Low confidence or', fontsize=8, ha='center', va='center')
    ax.text(13.25, 5.4, 'Miscellaneous', fontsize=8, ha='center', va='center')
    ax.text(13.25, 5.2, 'category detected', fontsize=8, ha='center', va='center')
    ax.text(13.25, 5, 'Mark for user', fontsize=8, ha='center', va='center')
    ax.text(13.25, 4.8, 'categorization', fontsize=8, ha='center', va='center')
    
    # Arrows for learning
    arrow_auto = FancyArrowPatch((5.5, 5.9), (4.5, 5.9),
                                arrowstyle='->', 
                                mutation_scale=15, 
                                color=colors['black'], 
                                linewidth=1)
    ax.add_patch(arrow_auto)
    ax.text(5, 6.2, 'HIGH\nCONFIDENCE', fontsize=8, ha='center', va='center', fontweight='bold')
    
    arrow_prompt = FancyArrowPatch((10.5, 5.9), (11.5, 5.9),
                                  arrowstyle='->', 
                                  mutation_scale=15, 
                                  color=colors['black'], 
                                  linewidth=1)
    ax.add_patch(arrow_prompt)
    ax.text(11, 6.2, 'LOW\nCONFIDENCE', fontsize=8, ha='center', va='center', fontweight='bold')
    
    # Arrow 9 (both paths continue)
    arrow9a = FancyArrowPatch((2.75, 4.7), (2.75, 4),
                             arrowstyle='->', 
                             mutation_scale=15, 
                             color=colors['black'], 
                             linewidth=1)
    ax.add_patch(arrow9a)
    
    arrow9b = FancyArrowPatch((13.25, 4.7), (13.25, 4),
                             arrowstyle='->', 
                             mutation_scale=15, 
                             color=colors['black'], 
                             linewidth=1)
    ax.add_patch(arrow9b)
    
    # Convergence arrows
    arrow_conv1 = FancyArrowPatch((2.75, 4), (7, 3.5),
                                 arrowstyle='->', 
                                 mutation_scale=15, 
                                 color=colors['black'], 
                                 linewidth=1)
    ax.add_patch(arrow_conv1)
    
    arrow_conv2 = FancyArrowPatch((13.25, 4), (9, 3.5),
                                 arrowstyle='->', 
                                 mutation_scale=15, 
                                 color=colors['black'], 
                                 linewidth=1)
    ax.add_patch(arrow_conv2)
    
    # Step 10: Generate Smart Title
    step10_box = Rectangle((6, 2.7), 4, 0.8, 
                          facecolor=colors['process'], 
                          edgecolor=colors['black'], 
                          linewidth=2)
    ax.add_patch(step10_box)
    ax.text(8, 3.1, 'GENERATE SMART TITLE\n"Category: Method HH:MM"', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Arrow 10
    arrow10 = FancyArrowPatch((8, 2.7), (8, 2),
                             arrowstyle='->', 
                             mutation_scale=20, 
                             color=colors['black'], 
                             linewidth=2)
    ax.add_patch(arrow10)
    
    # Step 11: Save to Firebase
    step11_box = Rectangle((6, 1.2), 4, 0.8, 
                          facecolor=colors['data'], 
                          edgecolor=colors['black'], 
                          linewidth=2)
    ax.add_patch(step11_box)
    ax.text(8, 1.6, 'SAVE TO FIREBASE\nWITH METADATA', 
            fontsize=10, fontweight='bold', ha='center', va='center')
    
    # Final success indicator
    success_circle = Circle((8, 0.5), 0.3, 
                           facecolor=colors['process'], 
                           edgecolor=colors['black'], 
                           linewidth=2)
    ax.add_patch(success_circle)
    ax.text(8, 0.5, 'OK', fontsize=14, ha='center', va='center', fontweight='bold')
    ax.text(8, 0.1, 'EXPENSE ADDED', fontsize=9, ha='center', va='center', fontweight='bold')
    
    # Final arrow
    arrow_final = FancyArrowPatch((8, 1.2), (8, 0.8),
                                 arrowstyle='->', 
                                 mutation_scale=20, 
                                 color=colors['black'], 
                                 linewidth=2)
    ax.add_patch(arrow_final)
    
    plt.tight_layout()
    return fig

def main():
    """Generate and save the SMS processing pipeline diagram."""
    print("Generating SMS Processing Pipeline Diagram...")
    
    # Create the diagram
    fig = create_sms_pipeline_diagram()
    
    # Save in PNG and JPG formats
    output_files = [
        ('research_paper/sms_processing_pipeline.png', 'PNG'),
        ('research_paper/sms_processing_pipeline.jpg', 'JPEG')
    ]
    
    for output_file, format_type in output_files:
        fig.savefig(output_file, dpi=300, bbox_inches='tight', 
                   facecolor='white', edgecolor='none', format=format_type.lower())
        print(f"✅ Saved: {output_file}")
    
    print("\n🎯 SMS Pipeline Diagram Generation Complete!")
    print("\nFiles generated:")
    print("📊 PNG format: High-resolution for papers (300 DPI)")
    print("📷 JPG format: Compressed image for presentations")
    print("\n📐 Dimensions: 16×20 inches (detailed flowchart)")
    print("🎨 Black and white professional formatting")
    print("📝 Complete SMS processing flow with decision points")
    print("📋 Ready for technical documentation!")
    
    # Show the plot
    plt.show()

if __name__ == "__main__":
    main()