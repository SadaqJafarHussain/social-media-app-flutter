List<String> userNames = [];
bool isUserUniqe(String username) {
  int number = 0;
  for (int i = 0; i <= (userNames.length) - 1; i++) {
    if (username == userNames[i]) {
      number++;
    }
  }
  if (number > 0) {
    return false;
  } else
    return true;
}
