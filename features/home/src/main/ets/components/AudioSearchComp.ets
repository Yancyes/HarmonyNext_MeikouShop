import { audio } from '@kit.AudioKit'
import { speechRecognizer } from '@kit.CoreSpeechKit'
import { Logger, permissionPlugin } from 'basic'

export enum VoiceState {
  DEFAULT,
  VOICING,
  VOICEOVER
}

@ComponentV2
export struct AudioSearchComp {
  @Local voiceState: VoiceState = VoiceState.DEFAULT
  @Local keyword: string = ''
  audioCapturer: audio.AudioCapturer | null = null
  asrEngine: speechRecognizer.SpeechRecognitionEngine | null = null
  sessionId: string = '10000'
  @Event onChange: (keyword: string) => void = () => {
  }
  @Event onComplete: (keyword: string) => void = () => {
  }

  async startRecord() {
   //---------- Speech Recognition ----------
    //Create an engine and return it via a Promise
    //Set the parameters for creating the engine
    let initParamsInfo: speechRecognizer.CreateEngineParams = {
      language: 'zh-CN',
      online: 1,
      extraParams: { "locate": "CN", "recognizerMode": "short" }
    };
    // callTheCreateEngineMethod
    this.asrEngine = await speechRecognizer.createEngine(initParamsInfo)

    // Create a callback object to listen for the recognition result (this pit, change later)
    let setListener: speechRecognizer.RecognitionListener = {
      // beginToIdentifySuccessfulCallbacks
      onStart(sessionId: string, eventMessage: string) {
        Logger.info(`onStart, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      // eventCallbacks
      onEvent(sessionId: string, eventCode: number, eventMessage: string) {
        Logger.info(`onEvent, sessionId: ${sessionId} eventCode: ${eventCode} eventMessage: ${eventMessage}`);
      },
      // Identify result callbacks, including intermediate and final results
      onResult: (sessionId: string, result: speechRecognizer.SpeechRecognitionResult) => {
        Logger.info(`onResult, sessionId: ${sessionId} sessionId: ${JSON.stringify(result)}`);
        this.onChange(result.result)
        this.keyword = result.result
      },
      // identifyTheCompletionCallback
      onComplete: (sessionId: string, eventMessage: string) => {
        this.onComplete(this.keyword)
        this.keyword = ''
        this.voiceState = VoiceState.VOICEOVER
        Logger.info(`onComplete, sessionId: ${sessionId} eventMessage: ${eventMessage}`);
      },
      //Error callback: The error code is returned by this method
      //For example, if an error code is returned, 1002200006 the recognition engine is busy and the engine is recognizing
      //For more error codes, see Error Code Reference
      onError(sessionId: string, errorCode: number, errorMessage: string) {
        Logger.error(`onError, sessionId: ${sessionId} errorCode: ${errorCode} errorMessage: ${errorMessage}`);
      }
    }
    // setUpACallback
    this.asrEngine.setListener(setListener);

    // callTheStartRecognitionMethod
    this.asrEngine.startListening({
      sessionId: this.sessionId,
      audioInfo: {
        audioType: 'pcm',
        sampleRate: 16000,
        soundChannel: 1,
        sampleBit: 16
      },
      extraParams: { "vadBegin": 2000, "vadEnd": 3000, "maxAudioDuration": 40000 }
    });


    //recordingsOptions
    let audioCapturerOptions: audio.AudioCapturerOptions = {
      streamInfo: {
        samplingRate: audio.AudioSamplingRate.SAMPLE_RATE_16000, // 采样率
        channels: audio.AudioChannel.CHANNEL_1, // 通道
        sampleFormat: audio.AudioSampleFormat.SAMPLE_FORMAT_S16LE, // 采样格式
        encodingType: audio.AudioEncodingType.ENCODING_TYPE_RAW // 编码格式
      },
      capturerInfo: {
        source: audio.SourceType.SOURCE_TYPE_MIC,
        capturerFlags: 0
      }
    };
    //instancing
    this.audioCapturer = await audio.createAudioCapturer(audioCapturerOptions);

    // recordingCallbackFunction
    this.audioCapturer.on('readData', (buffer: ArrayBuffer) => {
      // Passing the audio to speech recognition triggers a callback function
      this.asrEngine?.writeAudio(this.sessionId, new Uint8Array(buffer))
    });

    // turnOnRecording
    this.audioCapturer.start()
    // adjust The Recording Status
    this.voiceState = VoiceState.VOICING
  }

  async closeRecord() {
    // turnOffTheRecordingToFreeUpResources
    this.audioCapturer?.stop()
    this.audioCapturer?.release()

    // disable Identification To Release Resources
    this.asrEngine?.finish(this.sessionId)
    this.asrEngine?.shutdown()
    this.voiceState = VoiceState.VOICEOVER
  }

  aboutToAppear(): void {
    // requestPermissions
    permissionPlugin.requestPermissions(["ohos.permission.MICROPHONE"])
  }

  build() {
    Column() {
      if (this.voiceState !== VoiceState.DEFAULT) {
        Column({ space: 16 }) {
          if (this.voiceState === VoiceState.VOICING) {
            Text('请说，我在聆听...')
              .fontSize(14)
          } else if (this.voiceState === VoiceState.VOICEOVER && this.keyword === '') {
            Text('未检测到语音，请长按按钮重试')
              .fontSize(14)
          }
          Text() {
            Span('你可以这样说：')
            Span('太阳眼镜/冬款连衣裙')
              .fontColor($r('[basic].color.gray'))
          }
          .fontSize(12)
        }
        .justifyContent(FlexAlign.Center)
        .height(150)
      }
      Blank()
      Button() {
        Row({ space: 4 }) {
          Image($r('sys.media.ohos_ic_public_voice'))
            .width(16)
            .aspectRatio(1)
            .fillColor($r('[basic].color.white'))
          if (this.voiceState === VoiceState.VOICING) {
            Text('松开立即搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))
          } else {
            Text('长按语音搜索')
              .fontSize(14)
              .fontColor($r('[basic].color.white'))
          }
        }
      }
      .padding({ left: 12, right: 12 })
      .height(36)
      .linearGradient({
        angle: 135,
        colors: [[$r('[basic].color.linear_begin'), 0], [$r('[basic].color.linear_end'), 1]]
      })
      .margin({ bottom: 16 })
      .gesture(LongPressGesture()
        .onAction(() => {
          this.startRecord()
        })
        .onActionEnd(() => {
          this.closeRecord()
        })
        .onActionCancel(() => {
          this.closeRecord()
        }))
    }
    .layoutWeight(1)
    .width('100%')
    .backgroundImage($r('app.media.search_bg'))
    .backgroundImageSize(ImageSize.Contain)
    .backgroundImagePosition(Alignment.Bottom)
    .onVisibleAreaChange([0, 1], () => {
      this.keyword = ''
      this.voiceState = VoiceState.DEFAULT
    })
  }
}