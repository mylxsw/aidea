/// 该文件来源于 https://github.com/created-by-varun/flutter_pagination/blob/master/lib/pagination.dart

import 'package:askaide/page/component/theme/custom_theme.dart';
import 'package:flutter/material.dart';

class Pagination extends StatefulWidget {
  const Pagination({
    super.key,
    required this.numOfPages,
    required this.selectedPage,
    this.pagesVisible = 5,
    required this.onPageChanged,
  });

  final int numOfPages;
  final int selectedPage;
  final int pagesVisible;
  final Function onPageChanged;

  @override
  State<Pagination> createState() => _PaginationState();
}

class _PaginationState extends State<Pagination> {
  late int _startPage;
  late int _endPage;

  @override
  void initState() {
    super.initState();
    _calculateVisiblePages();
  }

  @override
  void didUpdateWidget(Pagination oldWidget) {
    super.didUpdateWidget(oldWidget);
    _calculateVisiblePages();
  }

  void _calculateVisiblePages() {
    /// If the number of pages is less than or equal to the number of pages visible, then show all the pages
    if (widget.numOfPages <= widget.pagesVisible) {
      _startPage = 1;
      _endPage = widget.numOfPages;
    } else {
      /// If the number of pages is greater than the number of pages visible, then show the pages visible
      int middle = (widget.pagesVisible - 1) ~/ 2;
      if (widget.selectedPage <= middle + 1) {
        _startPage = 1;
        _endPage = widget.pagesVisible;
      } else if (widget.selectedPage >= widget.numOfPages - middle) {
        _startPage = widget.numOfPages - (widget.pagesVisible - 1);
        _endPage = widget.numOfPages;
      } else {
        _startPage = widget.selectedPage - middle;
        _endPage = widget.selectedPage + middle;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final customColors = Theme.of(context).extension<CustomColors>()!;

    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        /// loop through the pages and show the page buttons
        for (int i = _startPage; i <= _endPage; i++)
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            child: TextButton(
              style: i == widget.selectedPage
                  ? ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent),
                    )
                  : ButtonStyle(
                      backgroundColor:
                          MaterialStateProperty.all(Colors.transparent)),
              onPressed: () => widget.onPageChanged(i),
              child: Text(
                '$i',
                style: i == widget.selectedPage
                    ? TextStyle(
                        color: customColors.linkColor,
                        fontSize: 14,
                        fontWeight: FontWeight.w700,
                      )
                    : TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w700,
                        color: customColors.weakLinkColor,
                      ),
              ),
            ),
          ),
      ],
    );
  }
}
