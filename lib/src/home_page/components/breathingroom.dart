import 'package:flutter/material.dart';

class BreathingRoom extends SliverFixedExtentList {
  BreathingRoom(double height, {super.key})
      : super(
          delegate: SliverChildBuilderDelegate(
            (BuildContext context, index) {
              return Container();
            },
            childCount: 1,
          ),
          itemExtent: height,
        );
}




