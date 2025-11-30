import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:henkanki/bloc.dart';

// git push のち flutter build web --release のち firebase deploy

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
      ),
      scrollBehavior: _MyCustomScrollBehavior(),
      home: BlocProvider(
        create: (_) => ConvertBloc(),
        child: const MyHomePage(),
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _State();
}

class _State extends State<MyHomePage> {
  final TextEditingController _textController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return BlocBuilder<ConvertBloc, String>(
          builder: (context, state) {
            final screenWidth = constraints.maxWidth;
            final screenHeight = constraints.maxHeight;
            final isHorizontal =
                screenWidth > 550 && screenWidth > screenHeight;
            final widgetHeight = isHorizontal
                ? screenHeight * 0.5
                : screenHeight * 0.2;
            final widgetWidth = isHorizontal ? screenWidth * 0.4 : screenWidth;
            final beforeWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: widgetWidth,
                  height: widgetHeight,
                  child: ColoredBox(
                    color: Color(0x80FFFFFF),
                    child: TextField(
                      controller: _textController,
                      maxLines: null,
                      expands: true,
                      textAlignVertical: TextAlignVertical.top,
                      keyboardType: TextInputType.multiline,
                      decoration: const InputDecoration(
                        labelText: 'テキストを入力してください',
                        border: OutlineInputBorder(gapPadding: 3.0),
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.white,
                    ),
                  ),
                  onPressed: _pasteFromClipboard,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      'クリップボードから貼り付け',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );

            final convertButton = FloatingActionButton(
              onPressed: () => context.read<ConvertBloc>().add(
                ConvertEvent(text: _textController.text),
              ),
              tooltip: '変換',
              child: Icon(
                isHorizontal ? Icons.arrow_forward : Icons.arrow_downward,
              ),
            );

            final afterWidget = Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  width: widgetWidth,
                  height: widgetHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: const Color(0x80FFFFFF),
                      border: BoxBorder.all(color: Colors.black),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: SelectableText(
                        context.read<ConvertBloc>().state,
                        style: TextStyle(fontSize: 16),
                        textAlign: TextAlign.start,
                      ),
                    ),
                  ),
                ),
                TextButton(
                  style: ButtonStyle(
                    backgroundColor: WidgetStatePropertyAll<Color>(
                      Colors.white,
                    ),
                  ),
                  onPressed: () =>
                      Clipboard.setData(ClipboardData(text: state)),
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      '変換結果をコピー',
                      style: TextStyle(fontSize: 16, color: Colors.black),
                    ),
                  ),
                ),
              ],
            );
            final stacked = isHorizontal
                ? Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      beforeWidget,
                      convertButton,
                      afterWidget,
                    ],
                  )
                : Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: <Widget>[
                      beforeWidget,
                      convertButton,
                      afterWidget,
                    ],
                  );

            return Scaffold(
              backgroundColor: Colors.white,
              body: Center(
                child: Stack(
                  children: [
                    Container(
                      decoration: BoxDecoration(
                        color: Colors.black,
                        image: DecorationImage(
                          image: AssetImage('assets/iMac.jpg'),
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    stacked,
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Future<void> _pasteFromClipboard() async {
    final ClipboardData? clipboardData = await Clipboard.getData(
      Clipboard.kTextPlain,
    );

    if (clipboardData != null && clipboardData.text != null) {
      setState(() {
        _textController.text = clipboardData.text!;
        _textController.selection = TextSelection.fromPosition(
          TextPosition(offset: _textController.text.length),
        );
      });

      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('クリップボードの内容を貼り付けました。')));
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('クリップボードにテキストデータがありません。')));
      }
    }
  }

  @override
  void dispose() {
    _textController.dispose();
    super.dispose();
  }
}

class _MyCustomScrollBehavior extends MaterialScrollBehavior {
  @override
  Set<PointerDeviceKind> get dragDevices => {
    PointerDeviceKind.touch,
    PointerDeviceKind.mouse,
  };
}
