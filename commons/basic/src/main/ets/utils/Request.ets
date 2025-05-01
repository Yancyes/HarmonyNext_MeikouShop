import axios, { AxiosError, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { Logger } from '../../../../Index';
import { promptAction } from '@kit.ArkUI';

interface APIErrorType {
  message: string
  msg: string
  code: number
}

//create axios instance
export const instance = axios.create({
  baseURL: 'https://meikou-api.itheima.net/',
  timeout: 20000,
})

//the Data Structure Returned By The Backend
interface HttpResponse<T> {
  code: number
  msg: string
  result: T
}

export type ResponseType<T> = AxiosResponse<HttpResponse<T>>

//interceptor of request
instance.interceptors.request.use((config: InternalAxiosRequestConfig) => {
  return config
}, (e: AxiosError) => {
  return Promise.reject(e)
})
//interceptor of response
instance.interceptors.response.use((response: AxiosResponse) => {
  return response
}, (e: AxiosError<APIErrorType>) => {
  Logger.error(e)
  if (e.response?.status === 400) {
    promptAction.showToast({
      message: e.response.data.message
    })
  } else if (e.response?.status == 401) {
    promptAction.showToast({
      message: '登录过期'
    })
  }
  return Promise.reject(e)
})


export class Https {
  static get<T>(url: string, params?: object): Promise<ResponseType<T>> {
    return instance.get<null, ResponseType<T>>(url, params)
  }

  static post<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.post<null, ResponseType<T>>(url, data)
  }

  static delete<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.delete<null, ResponseType<T>>(url, data)
  }

  static put<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.put<null, ResponseType<T>>(url, data)
  }
}
