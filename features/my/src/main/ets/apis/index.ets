import { AddressItem, Https, MkUser } from 'basic';

interface LoginData {
  account: string
  password: string
}

export interface RequestType {
  address: string;
  contact: string;
  isDefault: 0 | 1; // 0 默认 1 非默认
  receiver: string;
}

/**
 * @param id address ID */
export const setDefaultAddressAPI = (id: string) => {
  return Https.put<null>(`/member/address/${id}`, new Object({ isDefault: 0 }))
}

/**
 * @param id address ID */
export const delAddressAPI = (id: string) => {
  return Https.delete<null>(`/member/address/${id}`)
}

/**
 * @param data address type */
export const createAddressAPI = (data: RequestType) => {
  return Https.post<null>('/member/address', data)
}

/**
 * @param data loginFormType */
export const LoginApi = (data: LoginData) => {
  return Https.post<MkUser>('/login', data)
}

export const getAddressApi = () => {
  return Https.get<AddressItem[]>('/member/address')
}

/**
 * @param id address id
 * @param data address requestType */
export const editAddressAPI = (id: string, data: RequestType) => {
  return Https.put<null>(`/member/address/${id}`, data)
}