import { abilityAccessCtrl, bundleManager, Permissions } from '@kit.AbilityKit';

class PermissionPlugin {
  ///check single Permissions
  checkAccessToken(permission: Permissions) {
    try {
      const atManager = this.getAtManager()
      const bundleInfo =
        bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
      const tokenId = bundleInfo.appInfo.accessTokenId
      const grantStatus = atManager.checkAccessTokenSync(tokenId, permission)
      return grantStatus
    } catch (e) {
      return abilityAccessCtrl.GrantStatus.PERMISSION_DENIED
    }
  }

  //check Multiple Permissions
  async checkPermissions(permissions: Permissions[]) {
    for (let permission of permissions) {
      const grantStatus = this.checkAccessToken(permission)
      if (grantStatus === abilityAccessCtrl.GrantStatus.PERMISSION_DENIED) {
        return false
      }
    }
    return true
  }

  //first time
  async requestPermissions(permission: Permissions[]) {
    const atManager = this.getAtManager()
    const res = await atManager.requestPermissionsFromUser(getContext(), permission)
    const isAuth = res.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    return isAuth ? Promise.resolve() : Promise.reject()
  }

  //second time
  async requestPermissionOnSetting(permission: Permissions[]) {
    const atManager = this.getAtManager()
    const grantStatus = await atManager.requestPermissionOnSetting(getContext(), permission)
    const isAuth = grantStatus.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    return isAuth ? Promise.resolve() : Promise.reject()
  }

  //Apply for authorization from the user

  //get Manager
  private getAtManager() {
    return abilityAccessCtrl.createAtManager()
  }
}

export const permissionPlugin = new PermissionPlugin()