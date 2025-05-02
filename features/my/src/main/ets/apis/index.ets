import { Https, MkUser } from "basic"

interface LoginData {
  account: string
  password: string
}

export const LoginApi = (data: LoginData) => {
  return Https.post<MkUser>('/login', data)
}