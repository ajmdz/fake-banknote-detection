enum CategoricalClasses { fake_1k, fake_500, real_1k, real_500 }

extension CategoricalClassesExtension on CategoricalClasses {
  String get label {
    switch (this) {
      case CategoricalClasses.fake_1k:
        return "fake_1k";
      case CategoricalClasses.fake_500:
        return "fake_500";
      case CategoricalClasses.real_1k:
        return "real_1k";
      case CategoricalClasses.real_500:
        return "real_500";
    }
  }
}