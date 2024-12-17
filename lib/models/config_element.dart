class ConfigElement {
  bool available = false;
  String errorMessage = "not initialized";

  void success() {
    available = true;
    errorMessage = "";
  }
  void error(Object e) {
    available = false;
    errorMessage = '$e';
  }
}