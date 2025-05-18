import { AddressItem, Https, MkUser } from 'basic';
import { GetOrderParams, GetOrderResult } from '../viewmodel';

interface LoginData {
  account: string
  password: string
}

export interface RequestType {
  address: string;
  contact: string;
  isDefault: 0 | 1; // 0 default 1 !default
  receiver: string;
}

/**
 * @param id string */
export const setDefaultAddressAPI = (id: string) => {
  return Https.put<null>(`/member/address/${id}`, new Object({ isDefault: 0 }))
}

/**
 * @param id string */
export const delAddressAPI = (id: string) => {
  return Https.delete<null>(`/member/address/${id}`)
}

/**
 * @param data RequestType */
export const createAddressAPI = (data: RequestType) => {
  return Https.post<null>('/member/address', data)
}

/**
 * @param data loginData */
export const LoginApi = (data: LoginData) => {
  return Https.post<MkUser>('/login', data)
}

export const getAddressApi = () => {
  return Https.get<AddressItem[]>('/member/address')
}

/**
 * @param id string
 * @param data RequestType */
export const editAddressAPI = (id: string, data: RequestType) => {
  return Https.put<null>(`/member/address/${id}`, data)
}

/**
 * @param params GetOrderParams */
export const getOrderApi = (params: GetOrderParams) => {
  return Https.get<GetOrderResult>('/member/order', { params })
}

/**
 * @param id string */
export const consignmentApi = (id: string) => {
  return Https.get<null>(`/member/order/consignment/${id}`)
}