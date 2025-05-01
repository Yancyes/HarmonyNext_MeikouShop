import { abilityAccessCtrl, bundleManager, common, Permissions } from '@kit.AbilityKit';

class PermissionPlugin {
  ///check single Permissions
  checkAccessToken(permission: Permissions) {
    try {
      const atManager = this.getAtManager()
      const bundleInfo = this.getBundleInfo()
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

  //Apply for authorization from the user
  //first time
  async requestPermissions(permission: Permissions[]) {
    const atManager = this.getAtManager()
    const res = await atManager.requestPermissionsFromUser(getContext(), permission)
    const isAuth = res.authResults.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    return isAuth ? Promise.resolve() : this.requestPermissionOnSetting(permission)
  }

  //second time
  async requestPermissionOnSetting(permission: Permissions[]) {
    const atManager = this.getAtManager()
    const grantStatus = await atManager.requestPermissionOnSetting(getContext(), permission)
    const isAuth = grantStatus.every(item => item === abilityAccessCtrl.GrantStatus.PERMISSION_GRANTED)
    return isAuth ? Promise.resolve() : Promise.reject()
  }

  openPermissionSettingPage() {
    const ctx = getContext() as common.UIAbilityContext
    const bundleInfo = this.getBundleInfo()
    ctx.startAbility({
      bundleName: 'com.huawei.hmos.settings',
      abilityName: 'com.huawei.hmos.settings.MainAbility',
      uri: 'application_info_entry',
      parameters: {
        // openTheSettingsPageByPackageName
        pushParams: bundleInfo.name
      }
    })
  }

  //get BundleInfo
  private getBundleInfo() {
    return bundleManager.getBundleInfoForSelfSync(bundleManager.BundleFlag.GET_BUNDLE_INFO_WITH_APPLICATION)
  }

  //get Manager
  private getAtManager() {
    return abilityAccessCtrl.createAtManager()
  }
}

export const permissionPlugin = new PermissionPlugin()