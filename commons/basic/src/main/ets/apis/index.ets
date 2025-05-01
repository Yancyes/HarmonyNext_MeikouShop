import { GoodsItems, Https } from ".."

/**
 * @param limit getData
 * @default 6 */
export const getGuessLikeApi = (limit: number = 6) => {
  return Https.get<GoodsItems>('/home/goods/guessLike', new Object({
    limit
  }))
}