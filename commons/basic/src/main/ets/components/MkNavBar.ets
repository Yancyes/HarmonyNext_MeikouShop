import { SafeAreaConstants } from '..'

@ComponentV2
export struct MkNavbar {
  // topSecurityArea
  safeTop: number = AppStorage.get(SafeAreaConstants.TOP) as number
  @Param @Once title: string = ''
  @Param @Once leftIcon: ResourceStr = $r('app.media.ic_public_left')
  @Param @Once rightIcon: ResourceStr = $r('app.media.ic_public_more')
  @Param @Once showLeftIcon: boolean = true
  @Param @Once showRightIcon: boolean = false
  // text + Icon Color
  @Param @Once color: ResourceColor = $r('app.color.black')
  // backgroundColor
  @Param @Once bg: ResourceColor = $r('app.color.white')
  @BuilderParam
  customTitle: () => void = this.defaultTitle
  leftClickHandler: () => void = () => {
  }
  rightClickHandler: () => void = () => {
  }

  @Builder
  defaultTitle() {
    Text(this.title)
      .fontSize(16)
      .fontWeight(500)
      .layoutWeight(1)
      .textAlign(TextAlign.Center)
      .fontColor(this.color)
  }

  build() {
    Row() {
      Row() {
        if (this.showLeftIcon) {
          Image(this.leftIcon)
            .width(24)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(() => {
              this.leftClickHandler()
            })
        }

      }
      .width(50)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
      //center title
      if(this.customTitle){
        this.customTitle()
      }

      Row() {
        if (this.showRightIcon) {
          Image(this.rightIcon)
            .width(24)
            .aspectRatio(1)
            .fillColor(this.color)
            .onClick(() => {
              this.rightClickHandler()
            })
        }
      }
      .width(50)
      .aspectRatio(1)
      .justifyContent(FlexAlign.Center)
    }
    .width('100%')
    .height(50 + this.safeTop)
    .backgroundColor(this.bg)
    .padding({ top: this.safeTop })
  }
}