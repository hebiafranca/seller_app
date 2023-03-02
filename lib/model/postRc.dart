class PostRc {
  int _rc;
  int _id;

 PostRc(this._rc, this._id);

  int get rc => _rc;

  set rc(int value) {
    _rc = value;
  }

  int get id => _id;

  set id(int value) {
    _id = value;
  }
}