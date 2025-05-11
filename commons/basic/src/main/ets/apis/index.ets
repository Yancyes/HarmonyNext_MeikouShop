import { auth, CartGoods, GoodsItems, Https } from '..'
import { PersistenceV2 } from '@kit.ArkUI'

interface CheckAllParams {
  selected: boolean
}

interface UpdateParams {
  selected?: boolean
  count?: number
}

interface AddParams extends CountResult {
  skuId: string
}

interface CountResult {
  count: number
}

interface DeleteParams {
  ids: string[]
}

/**
 * @param limit getData
 * @default 6 */
export const getGuessLikeApi = (limit: number = 6) => {
  return Https.get<GoodsItems>('/home/goods/guessLike', new Object({
    limit
  }))
}

@ObservedV2
export class Cart {
  @Trace count: number = 0

  add(data: AddParams) {
    return Https.post<null>('/member/cart', data)
  }

  init() {
    return PersistenceV2.connect(Cart, () => new Cart())!
  }

  // getTheNumberOfCarts
  async getCount() {
    let count = 0
    // theUserIsLoggedInBeforeTheRequestIsMade
    const userInfo = auth.getUser()
    if (userInfo.token) {
      // getTheNumberOfCarts
      const res = await Https.get<CountResult>('/member/cart/count')
      // updateVariablesForGlobalStorage
      count = res.data.result.count
    }
    // storeTheNumberOfCartsGlobally
    this.init().count = count
  }

  async getList() {
    return Https.get<CartGoods[]>('/member/cart')
  }

  async updateGoods(skuId: string, data: UpdateParams) {
    return Https.put<CartGoods>(`/member/cart/${skuId}`, data)
  }

  async remove(data: DeleteParams) {
    return Https.delete<null>('/member/cart', { data: data })
  }

  async checkAll(data: CheckAllParams) {
    return Https.put<null>('/member/cart/selected', data)
  }
}

export const cart = new Cart()