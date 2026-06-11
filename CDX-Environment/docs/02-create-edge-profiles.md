# Create Edge profiles

Create separate Microsoft Edge profiles for the following test users so that sign-in state and MFA tokens don't collide:

- **Tenant administrator:** `admin@<TenantName>.onmicrosoft.com`
- **User:** `nestorw@<TenantName>.onmicrosoft.com`
- **User:** `irvins@<TenantName>.onmicrosoft.com`

## Steps to create each profile

Use a dedicated Edge profile per user to avoid conflicts with InPrivate browsing and cached sign-in state.

1. In Microsoft Edge, select your profile icon, then select **Add profile**.

   ![Set up new work profile in Edge](../images/cdx-mdx-002.png)

2. Select **Add an account**, then select **Sign in to sync data**. Sign in with the credentials provided in the lab email and complete the initial MFA setup.

   ![Add a new account in Edge](../images/cdx-mdx-003.png)

3. When prompted **"Stay signed in to all your apps"**, select **No, sign in to this app only** to avoid registering your device in the tenant.

   ![No, sign in to this app only — avoid registering your device in the tenant](../images/cdx-mdx-004.png)

   ![Edge profile preferences settings](../images/cdx-mdx-005.png)

> **Tip:** Repeat for each user (admin, Nestor, Irvin) so you can switch tenants quickly during the lab.
