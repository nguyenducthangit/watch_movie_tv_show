import 'package:equatable/equatable.dart';
import 'package:flutter/material.dart';

class OnboardingModel extends Equatable {
  final String title;
  final String description;
  final String imagePath;
  final EdgeInsets padding;

  const OnboardingModel({
    required this.title,
    required this.description,
    required this.imagePath,
    required this.padding,
  });

  @override
  List<Object?> get props => [title, description, imagePath];
}
