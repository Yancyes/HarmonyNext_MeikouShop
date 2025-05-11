import { BreakPointConstants } from '../constants/index'
import { AppStorageV2, display } from '@kit.ArkUI'
import { Logger } from '..'


interface BreakPointTypeOption<T> {
  xs?: T // watch
  sm?: T // phone
  md?: T // folding
  lg?: T // TV
}

/**
 * this is a break point util*/
export class BreakPointType<T> {
  private option: BreakPointTypeOption<T>

  /**
   * using scenario
   * @param option xs = Watch
   * sm = Phone
   * md = Folding
   * lg = TV
   */
  constructor(option: BreakPointTypeOption<T>) {
    this.option = option
  }

  getValue(currentBreakPoint: string) {
    switch (currentBreakPoint) {
      case "xs":
        return this.option.xs
      case "sm":
        return this.option.sm
      case "md":
        return this.option.md
      case "lg":
        return this.option.lg
      default:
        return undefined
    }
  }
}
@ObservedV2
export class CurrentBreakPoint {
  //current break point
  @Trace curBp: string = ''
  // init Storage V2
  init(){
    return AppStorageV2.connect(CurrentBreakPoint,()=>new CurrentBreakPoint())!
  }
  updateBreakPoint(windowWidth: number) {
    try {
      //Convert the unit of length from px to vp, (px divided by pixel density to get vp)
      let windowWidthVp = windowWidth / display.getDefaultDisplaySync().densityPixels
      //newBp is new BreakPoint
      let newBp: string = ''
      if (windowWidthVp < 320) {
        newBp = BreakPointConstants.XS
      } else if (windowWidthVp < 600) {
        newBp = BreakPointConstants.SM
      } else if (windowWidthVp < 840) {
        newBp = BreakPointConstants.MD
      } else {
        newBp = BreakPointConstants.LG
      }
      if (this.curBp !== newBp) {
        this.curBp = newBp
        //update data
        this.init().curBp = this.curBp
      }
    } catch (err) {
      Logger.error("getDisplayByIdSync failed err" + err.code)
    }
  }
}


export const currentBreakPoint = new CurrentBreakPoint()
