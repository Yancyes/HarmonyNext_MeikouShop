import axios, { AxiosError, AxiosRequestConfig, AxiosResponse, InternalAxiosRequestConfig } from '@ohos/axios';
import { auth, Logger, MkNavPathStack, ViewsConstants } from '../../../../Index';
import { promptAction } from '@kit.ArkUI';

interface APIErrorType {
  message: string
  msg: string
  code: number
}
export const baseURL = 'https://meikou-api.itheima.net/'
//create axios instance
export const instance = axios.create({
  baseURL,
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
  const user = auth.getUser()
  if (user.token) {
    config.headers.Authorization = `Bearer ${user.token}`
  }
  return config
}, (e: AxiosError) => {
  return Promise.reject(e)
})
//interceptor of response
instance.interceptors.response.use((response: AxiosResponse) => {

  return response
}, (e: AxiosError<APIErrorType>) => {
  Logger.error(e)
  // responseError
  if (e.response?.status === 400) {
    // A 400 is usually a parameter error, and the backend has a response error message
    promptAction.showToast({ message: e.response.data.message })
  } else if (e.response?.status === 401) {
    // 401 generallyTheTokenInformationIsIncorrect
    promptAction.showToast({ message: '登录信息已过期，请重新登录' })
    // clearUserInformation
    auth.removeUser()
    // jumpToTheLandingPage
    MkNavPathStack.pushPath({ name: ViewsConstants.LOGIN_VIEW })
  }
  return Promise.reject(e)
})


export class Https {
  static get<T>(url: string, params?: AxiosRequestConfig): Promise<ResponseType<T>> {
    return instance.get<null, ResponseType<T>>(url, params)
  }

  static post<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.post<null, ResponseType<T>>(url, data)
  }

  static delete<T>(url: string, data?: AxiosRequestConfig): Promise<ResponseType<T>> {
    return instance.delete<null, ResponseType<T>>(url, data)
  }

  static put<T>(url: string, data?: object): Promise<ResponseType<T>> {
    return instance.put<null, ResponseType<T>>(url, data)
  }
}
