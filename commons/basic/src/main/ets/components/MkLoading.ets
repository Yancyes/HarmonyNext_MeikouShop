@ComponentV2
export struct MkLoading {
  loadingWidth: number = 80
  build() {
    ImageAnimator()
      .images([
        {src:$r('app.media.loading_01')},
        {src:$r('app.media.loading_02')},
        {src:$r('app.media.loading_03')},
        {src:$r('app.media.loading_04')},
      ])
      .state(AnimationStatus.Running)
      .duration(200)
      .iterations(-1)
      .width(this.loadingWidth)
      .aspectRatio(3)
  }
}