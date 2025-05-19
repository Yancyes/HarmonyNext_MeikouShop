import { AppStorageV2 } from "@kit.ArkUI"
import { MkGoodsItem } from ".."

@ObservedV2
export class GuessLike {
  @Trace items: MkGoodsItem[] = []

  init() {
    return AppStorageV2.connect(GuessLike, () => new GuessLike())!
  }
}
export const guessLike = new GuessLike()