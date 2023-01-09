import 'package:flutter/material.dart';
import 'package:flutter/animation.dart';
import 'circle_painter.dart';
import 'curve_wave.dart';


class RipplesAnimation extends StatefulWidget {
  const RipplesAnimation({Key? key, this.size = 40.0, this.color = Colors.red,}) : super(key: key);
  final double size;
  final Color color;
  @override
  _RipplesAnimationState createState() => _RipplesAnimationState();
}

class _RipplesAnimationState extends State<RipplesAnimation> with TickerProviderStateMixin {
  late AnimationController _controller;
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 2000),
      vsync: this,
    )..repeat();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  Widget _button() {
    return Center(
      child: ClipRRect(
        borderRadius: BorderRadius.circular(widget.size),
        child: DecoratedBox(
          decoration: BoxDecoration(
            gradient: RadialGradient(
              colors: <Color>[
                widget.color,
                Color.lerp(widget.color!, Colors.black, .05)!
              ],
            ),
          ),
          child: ScaleTransition(
              scale: Tween(begin: 0.95, end: 1.0).animate(
                CurvedAnimation(
                  parent: _controller,
                  curve: const CurveWave(),
                ),
              ),
              child: Icon(Icons.pause, size: 44,color: Colors.white,)
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
        height: MediaQuery.of(context).size.height*0.3,
        width: MediaQuery.of(context).size.width*0.4,
        child: Center(
          child: CustomPaint(
            painter: CirclePainter(
              _controller,
              color: widget.color,
            ),
            child: SizedBox(
              width: widget.size * 4.125,
              height: widget.size * 4.125,
              child: _button(),
            ),
        ),
      ),
    );
  }
}