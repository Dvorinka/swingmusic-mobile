enum RepeatMode {
  off,
  one,
  all;

  String get displayName {
    switch (this) {
      case RepeatMode.off:
        return 'Off';
      case RepeatMode.one:
        return 'Repeat One';
      case RepeatMode.all:
        return 'Repeat All';
    }
  }

  RepeatMode next() {
    switch (this) {
      case RepeatMode.off:
        return RepeatMode.all;
      case RepeatMode.all:
        return RepeatMode.one;
      case RepeatMode.one:
        return RepeatMode.off;
    }
  }
}

enum ShuffleMode {
  off,
  on;

  String get displayName {
    switch (this) {
      case ShuffleMode.off:
        return 'Off';
      case ShuffleMode.on:
        return 'On';
    }
  }

  ShuffleMode toggle() {
    switch (this) {
      case ShuffleMode.off:
        return ShuffleMode.on;
      case ShuffleMode.on:
        return ShuffleMode.off;
    }
  }
}
