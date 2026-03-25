# Frontend Structure Archive (Pre-Removal)

Generated: 2026-03-25T12:19:11.039Z

This archive captures the storefront/frontend structure before admin-only extraction.

## Intent

- Preserve route/module/asset reference for future frontend rebuild.
- Keep admin/backend codebase lean in this project.

## Preserved Core (Not Removed)

- `src/app/admin/**`
- `src/app/api/admin/**`
- `src/modules/admin/**`
- Supabase schema/migrations and backend libs.

## Archived Frontend Trees

### `src/app/(main)`

- Files: 42
- Directories: 36
- Approx size: 101.8 KB

```text
src/app/(main)/
  - (home)/page.tsx
  - about/page.tsx
  - account/@dashboard/addresses/page.tsx
  - account/@dashboard/club/page.tsx
  - account/@dashboard/default.tsx
  - account/@dashboard/orders/details/[id]/page.tsx
  - account/@dashboard/orders/page.tsx
  - account/@dashboard/page.tsx
  - account/@dashboard/profile/page.tsx
  - account/@dashboard/reset-password/page.tsx
  - account/@dashboard/reviews/page.tsx
  - account/@dashboard/wallet/page.tsx
  - account/default.tsx
  - account/layout.tsx
  - account/loading.tsx
  - account/page.tsx
  - auth/confirm/page.tsx
  - cart/loading.tsx
  - cart/page.tsx
  - categories/[...category]/loading.tsx
  - categories/[...category]/page.tsx
  - categories/loading.tsx
  - categories/page.tsx
  - club/page.tsx
  - collections/[handle]/loading.tsx
  - collections/[handle]/page.tsx
  - collections/loading.tsx
  - collections/page.tsx
  - contact/page.tsx
  - install/install-page-client.tsx
  - install/page.tsx
  - layout.tsx
  - login/page.tsx
  - order/confirmed/[id]/loading.tsx
  - order/confirmed/[id]/page.tsx
  - policies/[slug]/page.tsx
  - products/[handle]/loading.tsx
  - products/[handle]/page.tsx
  - search/visual/page.tsx
  - store/loading.tsx
  - store/page.tsx
  - wishlist/page.tsx
```

### `src/app/(checkout)`

- Files: 4
- Directories: 2
- Approx size: 16.5 KB

```text
src/app/(checkout)/
  - checkout/error.tsx
  - checkout/loading.tsx
  - checkout/page.tsx
  - layout.tsx
```

### `src/app/api/cart`

- Files: 2
- Directories: 2
- Approx size: 1.0 KB

```text
src/app/api/cart/
  - restore/route.ts
  - route.ts
```

### `src/app/api/customer`

- Files: 1
- Directories: 1
- Approx size: 1.1 KB

```text
src/app/api/customer/
  - route.ts
```

### `src/app/api/storefront`

- Files: 5
- Directories: 6
- Approx size: 17.7 KB

```text
src/app/api/storefront/
  - layout-state/route.ts
  - products/route.ts
  - search/image/route.ts
  - search/route.ts
  - shipping-options/route.ts
```

### `src/app/api/products`

- Files: 1
- Directories: 1
- Approx size: 0.7 KB

```text
src/app/api/products/
  - route.ts
```

### `src/app/api/pincode`

- Files: 1
- Directories: 2
- Approx size: 1.6 KB

```text
src/app/api/pincode/
  - [code]/route.ts
```

### `src/app/api/easebuzz`

- Files: 1
- Directories: 2
- Approx size: 14.0 KB

```text
src/app/api/easebuzz/
  - callback/route.ts
```

### `src/app/api/payu`

- Files: 1
- Directories: 2
- Approx size: 13.4 KB

```text
src/app/api/payu/
  - callback/route.ts
```

### `src/modules/about`

- Files: 5
- Directories: 3
- Approx size: 13.2 KB

```text
src/modules/about/
  - components/hero-section.tsx
  - components/highlights-section.tsx
  - components/story-sections.tsx
  - constants.ts
  - templates/about-page.tsx
```

### `src/modules/account`

- Files: 21
- Directories: 19
- Approx size: 78.5 KB

```text
src/modules/account/
  - components/account-info/index.tsx
  - components/account-nav/index.tsx
  - components/address-book/index.tsx
  - components/address-card/add-address.tsx
  - components/address-card/edit-address-modal.tsx
  - components/auth-shell/index.tsx
  - components/order-card/index.tsx
  - components/order-overview/index.tsx
  - components/overview/index.tsx
  - components/phone-login/index.tsx
  - components/profile-billing-address/index.tsx
  - components/profile-email/index.tsx
  - components/profile-name/index.tsx
  - components/profile-password/index.tsx
  - components/profile-phone/index.tsx
  - components/review-card/index.tsx
  - components/reviews-overview/customer-reviews-modal.tsx
  - components/reviews-overview/index.tsx
  - templates/account-club-template.tsx
  - templates/account-layout.tsx
  - templates/login-template.tsx
```

### `src/modules/cart`

- Files: 11
- Directories: 10
- Approx size: 51.2 KB

```text
src/modules/cart/
  - components/cart-item-select/index.tsx
  - components/empty-cart-message/index.tsx
  - components/item/index.tsx
  - components/preview-item/index.tsx
  - components/sign-in-prompt/index.tsx
  - context/cart-store-context.tsx
  - templates/index.tsx
  - templates/items.tsx
  - templates/preview.tsx
  - templates/summary.tsx
  - utils/gift-wrap.ts
```

### `src/modules/catalog`

- Files: 8
- Directories: 3
- Approx size: 8.3 KB

```text
src/modules/catalog/
  - components/catalog-card-grid-skeleton.tsx
  - components/catalog-card-grid.tsx
  - components/catalog-card.tsx
  - components/catalog-landing.tsx
  - components/catalog-view-toggle.tsx
  - constants.ts
  - types.ts
  - utils/catalog-items.ts
```

### `src/modules/categories`

- Files: 1
- Directories: 2
- Approx size: 4.3 KB

```text
src/modules/categories/
  - templates/index.tsx
```

### `src/modules/chatbot`

- Files: 14
- Directories: 12
- Approx size: 91.0 KB

```text
src/modules/chatbot/
  - actions.ts
  - chatbot-flows.ts
  - components/chatbot-header/index.tsx
  - components/chatbot-input/index.tsx
  - components/chatbot-login-form/index.tsx
  - components/chatbot-messages/index.tsx
  - components/chatbot-widget/index.tsx
  - components/message-bubble/index.tsx
  - components/order-status-card/index.tsx
  - components/quick-reply-buttons/index.tsx
  - components/typing-indicator/index.tsx
  - context/chatbot-context.tsx
  - index.ts
  - types.ts
```

### `src/modules/checkout`

- Files: 26
- Directories: 25
- Approx size: 107.1 KB

```text
src/modules/checkout/
  - components/address-select/index.tsx
  - components/addresses/index.tsx
  - components/billing_address/index.tsx
  - components/checkout-steps/index.tsx
  - components/country-select/index.tsx
  - components/discount-code/index.tsx
  - components/error-message/index.tsx
  - components/payment-button/index.tsx
  - components/payment-container/index.tsx
  - components/payment-test/index.tsx
  - components/payment-wrapper/index.tsx
  - components/payment-wrapper/stripe-wrapper.tsx
  - components/payment/index.tsx
  - components/review/index.tsx
  - components/rewards-redemption/index.tsx
  - components/shipping-address/index.tsx
  - components/shipping-info/index.tsx
  - components/shipping/index.tsx
  - components/shipping/shipping-header.tsx
  - components/shipping/shipping-method-option.tsx
  - components/shipping/shipping-summary.tsx
  - components/submit-button/index.tsx
  - context/checkout-context.tsx
  - hooks/useCheckoutState.ts
  - templates/checkout-form/index.tsx
  - templates/checkout-summary/index.tsx
```

### `src/modules/collections`

- Files: 1
- Directories: 2
- Approx size: 3.0 KB

```text
src/modules/collections/
  - templates/index.tsx
```

### `src/modules/contact`

- Files: 2
- Directories: 2
- Approx size: 18.5 KB

```text
src/modules/contact/
  - contact.constants.ts
  - templates/contact-page.tsx
```

### `src/modules/home`

- Files: 13
- Directories: 13
- Approx size: 70.1 KB

```text
src/modules/home/
  - components/best-selling/index.tsx
  - components/category-marquee/index.tsx
  - components/exclusive-collections/index.tsx
  - components/exclusive-collections/server.tsx
  - components/featured-products/index.tsx
  - components/featured-products/product-rail/index.tsx
  - components/hero/index.tsx
  - components/hero/server.tsx
  - components/popular-toy-set/index.tsx
  - components/review-media-hub/index.tsx
  - components/shop-by-age/index.tsx
  - components/why-choose-us/index.tsx
  - lib/get-collection-products.ts
```

### `src/modules/layout`

- Files: 32
- Directories: 28
- Approx size: 155.9 KB

```text
src/modules/layout/
  - components/announcement-bar/index.tsx
  - components/cart-badge/index.tsx
  - components/cart-button/index.tsx
  - components/cart-dropdown/index.tsx
  - components/cart-sidebar/index.tsx
  - components/contact-hub/index.tsx
  - components/country-select/index.tsx
  - components/header/index.tsx
  - components/icon-button/index.tsx
  - components/main-navigation/index.tsx
  - components/mobile-menu/index.tsx
  - components/mobile-nav/index.tsx
  - components/pwa-install-prompt/PWAContext.tsx
  - components/pwa-install-prompt/index.tsx
  - components/search-drawer/index.tsx
  - components/search-modal/index.tsx
  - components/search/index.tsx
  - components/shop-by-age-dropdown/index.tsx
  - components/shop-mega-menu/index.tsx
  - components/side-menu/index.tsx
  - components/whatsapp-button/index.tsx
  - config/footer.ts
  - config/navigation.ts
  - context/cart-sidebar-context.tsx
  - context/layout-data-context.tsx
  - hooks/useAnimatedPlaceholder.ts
  - hooks/useBodyScrollLock.ts
  - hooks/useOnClickOutside.ts
  - hooks/useSearchResults.ts
  - hooks/useVoiceSearch.ts
  - templates/footer/index.tsx
  - templates/nav/index.tsx
```

### `src/modules/order`

- Files: 13
- Directories: 12
- Approx size: 41.8 KB

```text
src/modules/order/
  - components/cancel-order-button.tsx
  - components/clear-cart-on-mount/index.tsx
  - components/club-welcome-banner/index.tsx
  - components/help/index.tsx
  - components/item/index.tsx
  - components/items/index.tsx
  - components/order-details/index.tsx
  - components/order-summary/index.tsx
  - components/order-tracking.tsx
  - components/payment-details/index.tsx
  - components/shipping-details/index.tsx
  - templates/order-completed-template.tsx
  - templates/order-details-template.tsx
```

### `src/modules/products`

- Files: 25
- Directories: 19
- Approx size: 162.9 KB

```text
src/modules/products/
  - components/customer-reviews/index.tsx
  - components/frequently-bought-together/index.tsx
  - components/image-gallery/index.tsx
  - components/order-information/index.tsx
  - components/product-actions/index.tsx
  - components/product-actions/mobile-actions.tsx
  - components/product-actions/option-select.tsx
  - components/product-actions/share-modal.tsx
  - components/product-preview/index.tsx
  - components/product-preview/price.tsx
  - components/product-preview/quick-view-modal.tsx
  - components/product-price/index.tsx
  - components/product-tabs/accordion.tsx
  - components/product-tabs/index.tsx
  - components/recently-viewed-tracker.tsx
  - components/related-products/index.tsx
  - components/related-products/related-products-carousel.tsx
  - components/thumbnail/index.tsx
  - components/wishlist-button/index.tsx
  - context/wishlist.tsx
  - hooks/use-wishlist-count.ts
  - templates/index.tsx
  - templates/product-actions-wrapper/index.tsx
  - templates/product-info/index.tsx
  - utils/get-short-description.ts
```

### `src/modules/search`

- Files: 1
- Directories: 3
- Approx size: 14.0 KB

```text
src/modules/search/
  - components/VisualSearchInterface/index.tsx
```

### `src/modules/shipping`

- Files: 1
- Directories: 3
- Approx size: 9.4 KB

```text
src/modules/shipping/
  - components/free-shipping-price-nudge/index.tsx
```

### `src/modules/skeletons`

- Files: 4
- Directories: 3
- Approx size: 3.4 KB

```text
src/modules/skeletons/
  - components/skeleton-card-details.tsx
  - components/skeleton-line-item.tsx
  - components/skeleton-product-preview.tsx
  - templates/skeleton-related-products.tsx
```

### `src/modules/store`

- Files: 17
- Directories: 11
- Approx size: 84.6 KB

```text
src/modules/store/
  - components/filter-drawer/index.tsx
  - components/pagination/index.tsx
  - components/product-grid-section/index.tsx
  - components/product-grid-section/product-grid-skeleton.tsx
  - components/product-grid-section/utils.ts
  - components/refinement-list/index.tsx
  - components/refinement-list/sort-products/index.tsx
  - components/refinement-list/types.ts
  - components/results-toolbar/index.tsx
  - constants.ts
  - context/storefront-filters.tsx
  - templates/index.tsx
  - templates/paginated-products.tsx
  - utils/age-filter.ts
  - utils/category.ts
  - utils/collection.ts
  - utils/price-range.ts
```

### `src/modules/wishlist`

- Files: 4
- Directories: 4
- Approx size: 11.9 KB

```text
src/modules/wishlist/
  - components/wishlist-content.tsx
  - components/wishlist-page-client.tsx
  - templates/wishlist-page.tsx
  - util/recently-viewed.ts
```

### `src/modules/common`

- Files: 49
- Directories: 27
- Approx size: 86.6 KB

```text
src/modules/common/
  - components/breadcrumbs/index.tsx
  - components/button/index.tsx
  - components/cart-totals/index.tsx
  - components/catalog-layout/index.tsx
  - components/checkbox/index.tsx
  - components/delete-button/index.tsx
  - components/divider/index.tsx
  - components/error-boundary.tsx
  - components/filter-radio-group/index.tsx
  - components/input/index.tsx
  - components/interactive-link/index.tsx
  - components/lazy-load-section.tsx
  - components/line-item-options/index.tsx
  - components/line-item-price/index.tsx
  - components/line-item-unit-price/index.tsx
  - components/localized-client-link/index.tsx
  - components/modal/index.tsx
  - components/native-select/index.tsx
  - components/quantity-selector/index.tsx
  - components/radio/index.tsx
  - components/realtime-order-manager.tsx
  - components/safe-rich-text/index.tsx
  - components/side-drawer/index.tsx
  - components/skeleton/category-marquee-skeleton.tsx
  - components/skeleton/hero-skeleton.tsx
  - components/skeleton/product-grid-skeleton.tsx
  - components/skeletons/catalog-grid-skeleton.tsx
  - components/text/index.tsx
  - components/toast-display.tsx
  - context/catalog-loading-context.tsx
  - context/shipping-price-context.tsx
  - context/toast-context.tsx
  - icons/back.tsx
  - icons/bancontact.tsx
  - icons/chevron-down.tsx
  - icons/eye-off.tsx
  - icons/eye.tsx
  - icons/fast-delivery.tsx
  - icons/ideal.tsx
  - icons/map-pin.tsx
  - icons/nextjs.tsx
  - icons/package.tsx
  - icons/paypal.tsx
  - icons/placeholder-image.tsx
  - icons/refresh.tsx
  - icons/spinner.tsx
  - icons/trash.tsx
  - icons/user.tsx
  - icons/x.tsx
```

### `public/assets/images`

- Files: 33
- Directories: 1
- Approx size: 11293.9 KB

```text
public/assets/images/
  - 51acyqZLHsL._UF1000_1000_QL80.jpg
  - 51eBXKW5gRL._SL1500.jpg
  - 61K1TDQYuCL._SL1280.jpg
  - Gemini_Generated_Image_t4s3cnt4s3cnt4s3.png
  - H373b3e2614344291824ff29116a86506M.jpg
  - H9b572778112d43ce886ad0cc030523e4N.jpg
  - Hdba07b027a41.jpg
  - Hee58b635f526431faa4076d3a0750afeD.jpg
  - about-page.png
  - about_page.png
  - apexture.png
  - cloud-1.svg
  - cloud-2.svg
  - cloud-3.svg
  - cloud-4.svg
  - easy-return_14784975.png
  - f1_star1.svg
  - f1_star2.svg
  - f1_star3.svg
  - f1_star4.svg
  - f1_star5.svg
  - f1_star6.svg
  - footer-bottom-shape.svg
  - footer-doll-left.svg
  - footer-doll-right.svg
  - frictions-airplanes.jpg
  - gift-wrap.png
  - high-quality_16090192.png
  - offer_2941125.png
  - planet_869092.png
  - pwa-post.png
  - slider_default.png
  - toycker.png
```

### `public/assets/videos`

- Files: 10
- Directories: 1
- Approx size: 24108.0 KB

```text
public/assets/videos/
  - exclusive-1.mp4
  - exclusive-10.mp4
  - exclusive-2.mp4
  - exclusive-3.mp4
  - exclusive-4.mp4
  - exclusive-5.mp4
  - exclusive-6.mp4
  - exclusive-7.mp4
  - exclusive-8.mp4
  - exclusive-9.mp4
```

## Notes for Future Rebuild

- Previous auth entrypoint lived at `src/app/(main)/login/page.tsx`.
- OTP/magic-link flow used `src/app/api/auth/callback/route.ts` and `src/lib/data/otp.ts`.
- Frontend consumed product/cart/storefront APIs under `src/app/api/storefront`, `src/app/api/cart`, and related routes.
- Large static media existed under `public/assets/images` and `public/assets/videos`.
