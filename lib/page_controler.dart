import 'package:get/get.dart';
import 'package:just_audio/just_audio.dart';

class PageManagerController extends GetxController {
  ProgressBarState progressBarState = ProgressBarState(
    current: Duration.zero,
    buffered: Duration.zero,
    total: Duration.zero,
  );
  ButtonState buttonNotifier = ButtonState.paused;

  static const url =
      'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-2.mp3';
  late AudioPlayer audioPlayer;

  @override
  void onInit() {
    init();
    super.onInit();
  }

  void init() async {
    audioPlayer = AudioPlayer();
    await audioPlayer.setUrl(url);

    audioPlayer.playerStateStream.listen((playerState) {
      final isPlaying = playerState.playing;
      final processingState = playerState.processingState;
      if (processingState == ProcessingState.loading ||
          processingState == ProcessingState.buffering) {
        buttonNotifier = ButtonState.loading;
        update();
      } else if (!isPlaying) {
        buttonNotifier = ButtonState.paused;
        update();
      } else if (processingState != ProcessingState.completed) {
        buttonNotifier = ButtonState.playing;
        update();
      } else {
        // completed
        audioPlayer.seek(Duration.zero);
        audioPlayer.pause();
        update();
      }
    });

    audioPlayer.positionStream.listen((position) {
      final oldState = progressBarState;
      progressBarState = ProgressBarState(
        current: position,
        buffered: oldState.buffered,
        total: oldState.total,
      );
      update();
    });

    audioPlayer.bufferedPositionStream.listen((bufferedPosition) {
      final oldState = progressBarState;
      progressBarState = ProgressBarState(
        current: oldState.current,
        buffered: bufferedPosition,
        total: oldState.total,
      );
      update();
    });

    audioPlayer.durationStream.listen((totalDuration) {
      final oldState = progressBarState;
      progressBarState = ProgressBarState(
        current: oldState.current,
        buffered: oldState.buffered,
        total: totalDuration ?? Duration.zero,
      );
      update();
    });

    update();
  }

  void play() {
    audioPlayer.play();
    update();
  }

  void pause() {
    audioPlayer.pause();
    update();
  }

  void seek(Duration position) {
    audioPlayer.seek(position);
    update();
  }

  void dispose() {
    audioPlayer.dispose();
    update();
  }
}

class ProgressBarState {
  ProgressBarState({
    required this.current,
    required this.buffered,
    required this.total,
  });
  final Duration current;
  final Duration buffered;
  final Duration total;
}

enum ButtonState { paused, playing, loading }
