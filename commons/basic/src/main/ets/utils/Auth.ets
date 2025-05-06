import { PersistenceV2 } from '@kit.ArkUI'
import { cart } from '..'

export interface MkUser {
  token: string
  nickname: string
  avatar: string
  account: string
}

@ObservedV2
class Auth {
  @Trace
  user: MkUser = {
    token: '',
    nickname: '',
    avatar: '',
    account: ''
  }

  init() {
    return PersistenceV2.connect(Auth, () => new Auth())!
  }

  getUser() {
    return this.init().user
  }

  saveUser(user: MkUser) {
    this.init().user = user
    //updateTheCartQuantityWhenYouLogIn
    cart.getCount()
  }

  removeUser() {
    this.init().user = {} as MkUser
    //updateTheNumberOfCartsWhenYouLogOut
    cart.getCount()
  }
}

// exportInstancedObjects
export const auth = new Auth()