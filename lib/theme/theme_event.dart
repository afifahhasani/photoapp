part of 'theme_bloc.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();
}

class ThemeChanged extends ThemeEvent{
  final AppTheme theme;

  ThemeChanged({
    @required this.theme,
  });

  List<Object> get props => [theme];

}