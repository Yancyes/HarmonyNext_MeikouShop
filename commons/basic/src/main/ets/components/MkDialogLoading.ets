@CustomDialog
export struct MkDialogLoading {
  message: string = '加载中'
  controller: CustomDialogController

  build() {
    Column({ space: 10 }) {
      LoadingProgress()
        .width(48)
        .height(48)
        .color($r('app.color.white'))
      if (this.message) {
        Text(this.message)
          .fontSize(14)
          .fontColor($r('app.color.white'))
      }
    }
    .justifyContent(FlexAlign.Center)
    .width(120)
    .height(120)
    .backgroundColor('rgba(0,0,0,0.6)')
    .borderRadius(16)
    .onAppear(()=>{
      //There is a suspicious bug in the current version, and it will be closed with a delay in the pop-up window
      setTimeout(()=>{
        this.controller.close()
      },1000)
    })
  }
}