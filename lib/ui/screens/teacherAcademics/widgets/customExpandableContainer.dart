import 'dart:math';
import 'package:eschool_saas_staff/data/models/studyMaterial.dart';
import 'package:eschool_saas_staff/ui/screens/teacherAcademics/widgets/studyMaterialContainer.dart';
import 'package:eschool_saas_staff/ui/widgets/customCircularProgressIndicator.dart';
import 'package:eschool_saas_staff/ui/widgets/customRoundedButton.dart';
import 'package:eschool_saas_staff/ui/widgets/customTextContainer.dart';
import 'package:eschool_saas_staff/utils/constants.dart';
import 'package:eschool_saas_staff/utils/labelKeys.dart';
import 'package:eschool_saas_staff/utils/utils.dart';
import 'package:flutter/material.dart';

class CustomExpandableContainer extends StatefulWidget {
  final Widget contractedContentWidget;
  final Widget? expandedContentWidget;
  final String titleText;
  final List<StudyMaterial>? studyMaterials;
  final bool isStudyMaterialFile;
  //if functions not provided, the buttons won't show
  final Function()? onEdit;
  final Function()? onDelete;
  final bool isDeleteLoading;
  final Widget? customActionContainer;
  final Widget? customTitleWidget;
  const CustomExpandableContainer(
      {super.key,
      required this.contractedContentWidget,
      this.expandedContentWidget,
      required this.titleText,
      this.onEdit,
      this.onDelete,
      this.studyMaterials,
      this.isStudyMaterialFile = false,
      this.isDeleteLoading = false,
      this.customActionContainer,
      this.customTitleWidget});

  @override
  State<CustomExpandableContainer> createState() =>
      _CustomExpandableContainerState();
}

class _CustomExpandableContainerState extends State<CustomExpandableContainer>
    with TickerProviderStateMixin {
  int appearDisappearAnimationDurationMilliseconds = 600;

  late AnimationController _controller;
  late Animation<double> _animation;
  late Animation<double> _iconAngleAnimation;

  @override
  void initState() {
    _controller = AnimationController(
      duration:
          Duration(milliseconds: appearDisappearAnimationDurationMilliseconds),
      vsync: this,
    );
    _iconAngleAnimation = Tween<double>(begin: 0, end: 180)
        .animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _animation = CurvedAnimation(
      parent: _controller,
      curve: Curves.fastLinearToSlowEaseIn,
    );
    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _toggleContainer() {
    if (_animation.status != AnimationStatus.completed) {
      _controller.forward();
    } else {
      _controller.animateBack(
        0,
        duration: Duration(
            milliseconds: appearDisappearAnimationDurationMilliseconds),
        curve: Curves.fastLinearToSlowEaseIn,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.symmetric(vertical: appContentHorizontalPadding),
      child: Stack(
        alignment: Alignment.bottomCenter,
        children: [
          Container(
            margin:
                EdgeInsetsDirectional.only(bottom: appContentHorizontalPadding),
            padding: EdgeInsets.all(appContentHorizontalPadding),
            decoration: BoxDecoration(
              border: Border.all(color: Theme.of(context).colorScheme.tertiary),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    if (widget.customTitleWidget != null) ...[
                      widget.customTitleWidget!,
                      const SizedBox(
                        width: 5,
                      ),
                    ],
                    Expanded(
                      child: CustomTextContainer(
                        textKey: widget.titleText,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          fontSize: 15.0,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                    if (widget.customActionContainer != null) ...[
                      const SizedBox(
                        width: 5,
                      ),
                      widget.customActionContainer!
                    ],
                  ],
                ),
                const SizedBox(
                  height: 5,
                ),
                Divider(
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                const SizedBox(
                  height: 10,
                ),

                ///[widgets that always show]
                widget.contractedContentWidget,

                const SizedBox(
                  height: 5,
                ),

                SizeTransition(
                  sizeFactor: _animation,
                  axis: Axis.vertical,
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        ///[Custom widgets when it's expanded]
                        if (widget.expandedContentWidget != null)
                          widget.expandedContentWidget!,

                        ///[Study Materials]
                        if (widget.studyMaterials?.isNotEmpty ?? false) ...[
                          const SizedBox(
                            height: 5,
                          ),
                          Divider(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Text(
                            Utils.getTranslatedLabel(widget.isStudyMaterialFile
                                ? filesKey
                                : studyMaterialsKey),
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: 13,
                              color: Theme.of(context)
                                  .colorScheme
                                  .secondary
                                  .withValues(alpha: 0.76),
                            ),
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          ...List.generate(widget.studyMaterials!.length,
                              (index) {
                            return Padding(
                              padding: const EdgeInsets.only(bottom: 10),
                              child: StudyMaterialContainer(
                                showOnlyStudyMaterialTitles:
                                    widget.isStudyMaterialFile,
                                studyMaterial: widget.studyMaterials![index],
                                showEditAndDeleteButton: false,
                              ),
                            );
                          }),
                        ],

                        ///[Edit/Delete Buttons]
                        if (widget.onDelete != null ||
                            widget.onEdit != null) ...[
                          const SizedBox(
                            height: 5,
                          ),
                          Divider(
                            color: Theme.of(context).colorScheme.tertiary,
                          ),
                          const SizedBox(
                            height: 5,
                          ),
                          Align(
                            alignment: AlignmentDirectional.bottomEnd,
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                if (widget.onEdit != null) ...[
                                  CustomRoundedButton(
                                    height: 40,
                                    widthPercentage: 0.25,
                                    backgroundColor: Colors.transparent,
                                    buttonTitle: editKey,
                                    fontWeight: FontWeight.w500,
                                    titleColor:
                                        Theme.of(context).colorScheme.secondary,
                                    borderColor:
                                        Theme.of(context).colorScheme.secondary,
                                    showBorder: true,
                                    onTap: widget.onEdit,
                                    radius: 5,
                                  ),
                                ],
                                if (widget.onDelete != null &&
                                    widget.onEdit != null)
                                  const SizedBox(
                                    width: 10,
                                  ),
                                if (widget.onDelete != null) ...[
                                  CustomRoundedButton(
                                    height: 40,
                                    radius: 5,
                                    widthPercentage: 0.25,
                                    backgroundColor:
                                        Theme.of(context).colorScheme.error,
                                    buttonTitle: deleteKey,
                                    fontWeight: FontWeight.w500,
                                    showBorder: false,
                                    onTap: widget.onDelete,
                                    child: widget.isDeleteLoading
                                        ? const CustomCircularProgressIndicator()
                                        : null,
                                  ),
                                ]
                              ],
                            ),
                          )
                        ],
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          ///[Bottom Rounded Button for Expand/Contract]
          Align(
            alignment: Alignment.bottomCenter,
            child: InkWell(
              radius: 50,
              onTap: () {
                _toggleContainer();
              },
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context)
                      .colorScheme
                      .primary
                      .withValues(alpha: 0.8),
                ),
                padding: const EdgeInsets.all(5),
                child: AnimatedBuilder(
                  animation: _iconAngleAnimation,
                  builder: (context, child) {
                    return Transform.rotate(
                      angle: (pi * _iconAngleAnimation.value) / 180,
                      child: Icon(
                        Icons.arrow_drop_down,
                        color: Theme.of(context).colorScheme.surface,
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
