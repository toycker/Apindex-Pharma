# Toycker Frontend Architecture & Folder Structure

This document explains the frontend folder structure used in the Toycker project. The architecture is highly modular, deeply separating concerns based on "features" rather than file types. This pattern is excellent for scalability in a Next.js (App Router) project.

> [!NOTE]
> This document focuses **exclusively** on the customer-facing website frontend (storefront). The backend and admin panel structures (like `src/app/admin` and `src/modules/admin`) are entirely excluded to give you a clear, unobstructed view of the public website's architecture.
## High-Level Philosophy: Feature-Based Modules

Instead of grouping all components together (e.g., all buttons, headers, and product cards inside a massive `src/components` folder), Toycker uses a **Feature-Based Architecture** inside `src/modules`. Each distinct business feature or domain (like `home`, `cart`, `checkout`, `products`) gets its own isolated folder containing *everything* it needs to function—its own components, hooks, formatting logic, and templates.

---

## Folder Structure Breakdown

### 1. `src/app/` (Routing via App Router)
Next.js 13+ App Router is used here to define pages, layouts, and API routes.

- **Route Groups (`(main)`, `(checkout)`)**: Folders wrapped in parentheses are used to share layouts without adding path segments to the URL. 
  - For example, `src/app/(main)` contains the global `layout.tsx` (Navbar & Footer), meaning any route inside it (like `/about` or `/products`) automatically inherits that layout. `src/app/(checkout)` can have a completely separate, minimalist layout without a footer.
- **Pages & Context**: Files like `page.tsx`, `loading.tsx`, `error.tsx`, and `not-found.tsx` are kept minimal. Their primary job is to fetch data and pass it into "Templates" from the `modules/` folder.

### 2. `src/modules/` (The Core Frontend Engine)
This is where the actual UI and business logic live. It is divided by domain:

- **Domain Folders** (`home`, `cart`, `checkout`, `products`, `layout`, etc.)
  Inside each domain folder, you will typically find:
  - `/components`: Small, reusable, presentation-only pieces specific to this domain (e.g., `best-selling` or `hero` inside the `home` module).
  - `/templates`: Large, composition components that stitch smaller components together. Pages in `src/app` usually import these templates directly.
  - `/hooks` & `/context`: State management specific to that domain.
  
- **`src/modules/common/`**:
  This is the shared component library for the project. Small, highly reusable atomic UI components live here.
  - Examples: `button`, `input`, `modal`, `checkbox`, `skeleton`, `radio`.
  - If a component is used across multiple domains, it belongs here.

- **`src/modules/layout/`**:
  Handles the global application shell.
  - Contains `/templates/nav` and `/templates/footer`.
  - Imported directly by the Root Layouts in `src/app/(main)/layout.tsx`.

### 3. `src/lib/` (Core Configuration & Utilities)
This acts as the global nervous system of the app.
- **`/integrations` & External Services**: Code connecting to external APIs (e.g., `brevo.ts`, `payu.ts`, `easebuzz.ts`).
- **`/context` & `/store`**: Global application state that transcends any single domain.
- **`/constants` & `/types`**: Global TypeScript interfaces and app-wide constants.

### 4. `src/components/` (Minimal Project-Level Wrappers)
Unlike standard React apps, the `src/components` folder here is practically empty. It is reserved for high-level project configuration components that aren't visually related to the business domains, such as PWA wrappers (`pwa-client-wrapper.tsx`).

---

## How it Flows Together (Example)

If you navigate to the Homepage (`/`), here is how the architecture handles it:

1. **Routing Layer**: `src/app/(main)/(home)/page.tsx` catches the route.
2. **Layout Layer**: It is wrapped by `src/app/(main)/layout.tsx`, which pulls in the `<Nav />` and `<Footer />` templates from `src/modules/layout/templates/`.
3. **Template Layer**: The `page.tsx` fetches necessary initial data and renders a template from `src/modules/home/templates/`.
4. **Component Layer**: The home template stitches together individual bits from `src/modules/home/components/` (like `hero`, `best-selling`, `category-marquee`).
5. **Atomic Layer**: Those specific components might use basic foundational UI from `src/modules/common/components/` (like a `<Button>`).

## How to Implement This in a New Project

To replicate this scalable structure in a new Next.js project:

1. Setup Next.js with `src/app` App Router.
2. Create standard Route Groups in `app/` tailored to your layouts (e.g., `(main)` and `(checkout)`).
3. Create a `src/modules/` directory.
4. Separate your application into logical business features (e.g., `auth`, `profile`, `listings`).
5. Inside each module folder, standardize sub-directories: `/components`, `/templates`, `/actions`, `/hooks`.
6. Create `src/modules/common/` exclusively for your base UI design system (buttons, inputs).
7. Keep `src/app/page.tsx` files as thin as possible—they should basically only be data-fetchers that return a `Template` from the corresponding module.
