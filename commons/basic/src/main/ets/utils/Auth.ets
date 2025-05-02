import { PersistenceV2 } from '@kit.ArkUI'

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

  getUser(){
    return this.persistence().user
  }

  saveUser(user: MkUser) {
    this.persistence().user = user
  }

  removeUser() {
    PersistenceV2.remove(Auth)
  }

  private persistence() {
    return PersistenceV2.connect(Auth, () => new Auth())!
  }
}

// exportInstancedObjects
export const auth = new Auth()