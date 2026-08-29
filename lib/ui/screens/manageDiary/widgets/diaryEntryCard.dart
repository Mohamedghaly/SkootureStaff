import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:flutter/material.dart';

class DiaryEntryCard extends StatefulWidget {
  final Map<String, dynamic> entry;
  final Function(String) onDelete;

  const DiaryEntryCard({
    super.key,
    required this.entry,
    required this.onDelete,
  });

  @override
  State<DiaryEntryCard> createState() => _DiaryEntryCardState();
}

class _DiaryEntryCardState extends State<DiaryEntryCard> {
  bool _isExpanded = false;

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
    });
  }

  @override
  Widget build(BuildContext context) {
    final bool isPositive = widget.entry['type'] == 'positive';

    return Container(
      margin: EdgeInsets.only(
        left: appContentHorizontalPadding,
        right: appContentHorizontalPadding,
        bottom: 15,
      ),
      padding: EdgeInsets.all(appContentHorizontalPadding),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surface,
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header Row with Category and Timestamp
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Category Tag with flexible width
              Flexible(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                  decoration: BoxDecoration(
                    color: Theme.of(context)
                        .colorScheme
                        .primary
                        .withValues(alpha: 0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: CustomTextContainer(
                    textKey: widget.entry['category'] ?? '--',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ),

              const SizedBox(width: 8),

              // Timestamp
              CustomTextContainer(
                textKey: widget.entry['timestamp'] ?? '',
                style: TextStyle(
                  fontSize: 12,
                  color: Theme.of(context)
                      .colorScheme
                      .secondary
                      .withValues(alpha: 0.7),
                ),
              ),

              const SizedBox(width: 8),

              // Expand/Collapse Button - Circular with arrow
              GestureDetector(
                onTap: _toggleExpanded,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  width: 24,
                  height: 24,
                  decoration: BoxDecoration(
                    color: _isExpanded
                        ? Theme.of(context)
                            .colorScheme
                            .primary // Dark teal/blue when active
                        : Theme.of(context)
                            .colorScheme
                            .primary
                            .withValues(alpha: 0.2), // Light blue when inactive
                    shape: BoxShape.circle,
                  ),
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 200),
                    child: Icon(
                      _isExpanded
                          ? Icons.arrow_drop_up // Upward arrow when expanded
                          : Icons
                              .arrow_drop_down, // Downward arrow when collapsed
                      key: ValueKey(_isExpanded), // Key for smooth transition
                      size: 24,
                      color: _isExpanded
                          ? Colors.white // White arrow when active
                          : Theme.of(context)
                              .colorScheme
                              .primary, // Dark blue arrow when inactive
                    ),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 14),

          // First Divider
          Container(
            height: 1,
            color:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.9),
          ),

          const SizedBox(height: 14),

          // Entry Title with Color Indicator
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: 8,
                height: 8,
                margin: const EdgeInsets.only(top: 6),
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isPositive ? Colors.green : Colors.red,
                ),
              ),

              const SizedBox(width: 8),

              // Title
              Expanded(
                child: CustomTextContainer(
                  textKey: widget.entry['title'] ?? '',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: isPositive ? Colors.green : Colors.red,
                  ),
                  maxLines: _isExpanded ? null : 1,
                  overflow: _isExpanded
                      ? TextOverflow.visible
                      : TextOverflow.ellipsis,
                ),
              ),
            ],
          ),

          const SizedBox(height: 8),

          // Entry Description - Expandable
          Padding(
            padding: const EdgeInsets.only(left: 16),
            child: CustomTextContainer(
              textKey: widget.entry['description'] ?? '',
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context)
                    .colorScheme
                    .secondary
                    .withValues(alpha: 0.8),
                height: 1.4,
              ),
              maxLines: _isExpanded ? null : 3,
              overflow:
                  _isExpanded ? TextOverflow.visible : TextOverflow.ellipsis,
            ),
          ),

          // Action Buttons (Edit/Delete) - Only shown when expanded and showActions is true
          if (_isExpanded && (widget.entry['showActions'] ?? false)) ...[
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                const SizedBox(width: 12),

                // Delete Button
                GestureDetector(
                  onTap: () => widget.onDelete(widget.entry['id']),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.error,
                      borderRadius: BorderRadius.circular(6),
                    ),
                    child: const CustomTextContainer(
                      textKey: 'delete',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w500,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],

          // Subject Information Section - Always visible
          const SizedBox(height: 16),

          // First Divider
          Container(
            height: 1,
            color:
                Theme.of(context).colorScheme.tertiary.withValues(alpha: 0.9),
          ),

          const SizedBox(height: 12),

          // Subject Row with Second Divider
          if (widget.entry['subject'] != null) ...[
            Row(
              children: [
                // Subject Label
                CustomTextContainer(
                  textKey: subjectKey,
                  style: TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                    color: Theme.of(context)
                        .colorScheme
                        .secondary
                        .withValues(alpha: 0.8),
                  ),
                ),

                const SizedBox(width: 12),

                // Vertical Divider
                Container(
                  width: 1,
                  height: 16,
                  color: Theme.of(context)
                      .colorScheme
                      .tertiary
                      .withValues(alpha: 0.9),
                ),

                const SizedBox(width: 12),

                // Subject Name
                Expanded(
                  child: CustomTextContainer(
                    textKey: widget.entry['name_with_type'] ?? noSubjectKey,
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.secondary,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ],
      ),
    );
  }
}
