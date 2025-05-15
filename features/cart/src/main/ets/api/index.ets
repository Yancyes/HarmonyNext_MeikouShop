import { Https } from 'basic'

import { CreateOrderParams, CreateOrderResult, PreOrder } from '../viewmodel'

/**
 * orders GetBilling Information*/
export const getOrderPreApi = () => {
  return Https.get<PreOrder>('/member/order/pre')
}

/**
 * order Management Add New Orders
 * @param data CreateOrderType */
export const createOrderApi = (data: CreateOrderParams) => {
  return Https.post<CreateOrderResult>('/member/order', data)
}