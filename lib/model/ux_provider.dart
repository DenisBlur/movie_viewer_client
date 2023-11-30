import 'dart:async';
import 'package:flutter/widgets.dart';

class UxProvider extends ChangeNotifier {

  Timer? _timer;

  PageController pageController = PageController();

  bool _showUserPanel = false;
  bool _showAdminPanel = false;
  bool _showControls = false;
  bool _showVolume = false;
  bool seek = false;
  bool _showButtonChangeFilm = false;

  bool get showVolume => _showVolume;

  set showVolume(bool value) {
    _showVolume = value;
    notifyListeners();
  }

  bool get showButtonChangeFilm => _showButtonChangeFilm;

  set showButtonChangeFilm(bool value) {
    _showButtonChangeFilm = value;
    notifyListeners();
  }

  bool get showUserPanel => _showUserPanel;

  set showUserPanel(bool value) {
    _showUserPanel = value;
    notifyListeners();
  }

  bool get showAdminPanel => _showAdminPanel;

  set showAdminPanel(bool value) {
    _showAdminPanel = value;
    notifyListeners();
  }

  bool get showControls => _showControls;

  set showControls(bool value) {
    _showControls = value;
    notifyListeners();
  }

  void animateWelcomePage(int page) {
    pageController.animateToPage(page, duration: const Duration(milliseconds: 650), curve: Curves.fastEaseInToSlowEaseOut);
    //showButtonChangeFilm = page == 2;
  }

  void controlsBase() {
    if (_timer != null && _timer!.isActive) {
      _timer!.cancel();
    }
    if(!_showAdminPanel && !_showUserPanel) {
      _timer = Timer(const Duration(seconds: 1), () {
        if(!showVolume && !seek) {
          showControls = false;
        }
      });
    }

    showControls = true;
  }
}
