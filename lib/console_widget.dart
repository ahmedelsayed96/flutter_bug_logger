import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_easylogger/logger_printer.dart';

import 'src/console_util.dart';
import 'src/log_mode.dart';

class ConsoleWidget extends StatefulWidget {
  ConsoleWidget({Key? key}) : super(key: key);

  @override
  _ConsoleWidgetState createState() => _ConsoleWidgetState();
}

class _ConsoleWidgetState extends State<ConsoleWidget> {
  late ScrollController _controller;

  late TextSelectionControls _selectionControl;

  late TextEditingController _textController;
  static const int _levelDefault = -1;

  String _filterStr = "";

  int _logLevel = _levelDefault;
  bool _isLarge = false;

  String _levelName = "all";

  double _marginTop = 0;

  // final Color _curreetLeveColor = ConsoleUtil.getLevelColor(_logLevel);

  final double _mangerSize = 50;

  final GlobalKey _globalKey = GlobalKey();

  double _currendDy = 0;

  @override
  void initState() {
    _controller = ScrollController();
    _selectionControl = MaterialTextSelectionControls();
    _textController = TextEditingController();

    WidgetsBinding.instance?.addPostFrameCallback((timeStamp) {
      // print("-----------${context.size!.height}");
      // _currendDy = context.size!.height;
      RenderBox renderObject =
          _globalKey.currentContext?.findRenderObject() as RenderBox;
      var size = _globalKey.currentContext?.size;
      _currendDy = renderObject.localToGlobal(Offset.zero).dy;
      print(
          "${renderObject.localToGlobal(Offset.zero).dy}-----------${context.size!.height}");
    });

    super.initState();
  }

  @override
  void dispose() {
    _controller.dispose();
    _textController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return _buildDraggable1();
  }

  Widget _buildDraggable() {
    return Draggable(
      // key:_globalKey,
      axis: Axis.vertical,
      feedback: _buildDragView(),
      child: _buildDragView(),
      childWhenDragging: Container(),
      // onDragEnd: (detail) {
      //   createDragTarget(offset: detail.offset);
      // },
    );
  }

  Widget _buildDraggable1() {
    return Container(
      key: _globalKey,
      margin: EdgeInsets.only(top: _marginTop),
      child: Draggable(
        axis: Axis.vertical,
        child: Container(
          height: 120,
          width: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.red, borderRadius: BorderRadius.circular(10)),
          child: Text(
            '孟',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        feedback: Container(
          height: 120,
          width: 120,
          alignment: Alignment.center,
          decoration: BoxDecoration(
              color: Colors.blue, borderRadius: BorderRadius.circular(10)),
          child: Text(
            '孟',
            style: TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
        childWhenDragging: Container(),
        onDragEnd: (DraggableDetails details) {
          setState(() {
            double offY = 0;
            if (details.offset.dy - _currendDy < 0) {
              offY = 0;
            } else {
              offY = details.offset.dy - _currendDy;
            }
            _marginTop = offY;

          });
        },
      ),
    );
  }

  Widget _buildDragView() {
    return LayoutBuilder(builder: (context, constraints) {
      return Column(
        children: [
          Container(
            height:
                _isLarge ? constraints.biggest.height - _mangerSize - 100 : 200,
            width: constraints.biggest.width,
            color: Colors.black,
            child: ValueListenableBuilder<LogModeValue>(
              valueListenable: notifier,
              builder:
                  (BuildContext context, LogModeValue model, Widget? child) {
                return _buildLogWidget(model);
              },
            ),
          ),
          Container(
            height: _mangerSize,
            width: constraints.biggest.width,
            color: Colors.grey,
            child: Row(
              children: [
                IconButton(
                  onPressed: _clearLog,
                  icon: Icon(Icons.clear),
                ),
                IconButton(
                  onPressed: _showCupertinoActionSheet,
                  icon: Icon(Icons.print),
                ),
                Text(
                  _levelName,
                  style: TextStyle(color: ConsoleUtil.getLevelColor(_logLevel)),
                ),
                const SizedBox(
                  width: 5,
                ),
                Expanded(
                  child: _buildTextFiled(),
                ),
                IconButton(
                  onPressed: _changeSize,
                  icon:
                      Icon(_isLarge ? Icons.crop : Icons.aspect_ratio_outlined),
                ),
              ],
            ),
          ),
        ],
      );
    });
  }

  Widget _buildLogWidget(LogModeValue model) {
    List<TextSpan> spanList = [];
    List<LogMode> modeList = model.logModeList;
    for (int i = modeList.length - 1; i >= 0; i--) {
      LogMode logMode = modeList[i];
      TextStyle _logStyle = TextStyle(
          color: ConsoleUtil.getLevelColor(logMode.level),
          fontSize: 15,
          // fontFamily: 'monospace',
          decoration: TextDecoration.none,
          fontWeight: FontWeight.w400);

      // TextStyle _logStyle =GoogleFonts.oxygenMono(color: ConsoleUtil.getLevelColor(logMode.level),);
      TextSpan span = TextSpan(
        children: [
          TextSpan(
            text: "${logMode.logMessage}\n",
            style: _logStyle,
          ),
        ],
      );
      // 过滤日志
      if ((_logLevel == logMode.level || _logLevel == _levelDefault) &&
          logMode.logMessage != null &&
          logMode.logMessage!.contains(_filterStr)) {
        spanList.add(span);
      }
    }

    return Scrollbar(
      // controller: _controller,
      scrollbarOrientation: ScrollbarOrientation.bottom,

      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.all(8.0),
        primary: true,
        child: SelectableText.rich(
          TextSpan(
            children: spanList,
          ),
          selectionControls: _selectionControl,
        ),
      ),
    );
  }

  /// 清除日志
  void _clearLog() {
    notifier.value = LogModeValue();
  }

  /// 过滤日志
  Future _showCupertinoActionSheet() async {
    var result = await showCupertinoModalPopup(
        context: context,
        builder: (context) {
          return CupertinoActionSheet(
            title: const Text('提示'),
            message: const Text('选择过滤日志级别？'),
            actions: [
              CupertinoActionSheetAction(
                child: const Text('清除过滤'),
                onPressed: () {
                  filterLog(context, _levelDefault);
                },
                isDefaultAction: _logLevel != _levelDefault,
                isDestructiveAction: _logLevel == _levelDefault,
              ),
              CupertinoActionSheetAction(
                child: const Text('verbose'),
                onPressed: () {
                  filterLog(context, LoggerPrinter.verbose);
                },
                isDefaultAction: _logLevel != LoggerPrinter.verbose,
                isDestructiveAction: _logLevel == LoggerPrinter.verbose,
              ),
              CupertinoActionSheetAction(
                child: const Text('debug'),
                onPressed: () {
                  filterLog(context, LoggerPrinter.debug);
                },
                isDefaultAction: _logLevel != LoggerPrinter.debug,
                isDestructiveAction: _logLevel == LoggerPrinter.debug,
              ),
              CupertinoActionSheetAction(
                child: const Text('info'),
                onPressed: () {
                  filterLog(context, LoggerPrinter.info);
                },
                isDefaultAction: _logLevel != LoggerPrinter.info,
                isDestructiveAction: _logLevel == LoggerPrinter.info,
              ),
              CupertinoActionSheetAction(
                child: const Text('warn'),
                onPressed: () {
                  filterLog(context, LoggerPrinter.warn);
                },
                isDefaultAction: _logLevel != LoggerPrinter.warn,
                isDestructiveAction: _logLevel == LoggerPrinter.warn,
              ),
              CupertinoActionSheetAction(
                child: const Text('error'),
                onPressed: () {
                  filterLog(context, LoggerPrinter.error);
                },
                isDestructiveAction: _logLevel == LoggerPrinter.error,
                isDefaultAction: _logLevel != LoggerPrinter.error,
              ),
            ],
            cancelButton: CupertinoActionSheetAction(
              child: const Text('取消'),
              onPressed: () {
                Navigator.of(context).pop('cancel');
              },
            ),
          );
        });
  }

  /// 过滤log
  void filterLog(BuildContext context, int level) {
    if (mounted) {
      setState(() {
        _logLevel = level;
        _setLevelName();
      });
    }
    Navigator.of(context).pop('delete');
  }

  /// 更改大小
  void _changeSize() {
    if (mounted) {
      setState(() {
        _isLarge = !_isLarge;
        _setLevelName();
      });
    }
  }

  /// 得到当前的名字
  void _setLevelName() {
    switch (_logLevel) {
      case _levelDefault:
        _levelName = "all";
        break;
      case LoggerPrinter.verbose:
        _levelName = "verbose";
        break;
      case LoggerPrinter.debug:
        _levelName = "debug";
        break;
      case LoggerPrinter.info:
        _levelName = "info";
        break;
      case LoggerPrinter.warn:
        _levelName = "warn";
        break;
      case LoggerPrinter.error:
        _levelName = "error";
        break;
    }
  }

  Widget _buildTextFiled() {
    return Container(
      margin: const EdgeInsets.all(5),
      padding: EdgeInsets.only(left: 15),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
      ),
      child: TextField(
        autofocus: false,
        controller: _textController,
        onChanged: (value) {
          _filterText(value);
        },
        textInputAction: TextInputAction.done,
        decoration: InputDecoration(
          hintText: "过滤日志",
          suffixIcon: IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _textController.clear();
              _filterText("");
            },
          ),
          border: InputBorder.none,
        ),
      ),
    );
  }

  void _filterText(String value) {
    setState(() {
      _filterStr = value;
    });
  }

  Widget createDragTarget({Offset? offset}) {
    bool isLeft = true;
    if (offset!.dx + 100 > MediaQuery.of(context).size.width / 2) {
      isLeft = false;
    }

    double maxY = MediaQuery.of(context).size.height - 100;
    return Positioned(
        top: offset.dy < 50
            ? 50
            : offset.dy < maxY
                ? offset.dy
                : maxY,
        left: isLeft ? 0 : null,
        right: isLeft ? null : 0,
        child: DragTarget(
          onWillAccept: (data) {
            print('onWillAccept: $data');
            return true;
          },
          onAccept: (data) {
            print('onAccept: $data');
            // refresh();
          },
          onLeave: (data) {
            print('onLeave');
          },
          builder: (BuildContext context, List incoming, List rejected) {
            return _buildDraggable();
          },
        ));
  }
}