import type { Metadata } from "next"
import ContactPageTemplate from "@modules/contact/templates/contact-page"

export const metadata: Metadata = {
  title: "Contact",
  description:
    "Contact Apindex Pharmaceuticals for partnership inquiries, clinical manufacturing discussions, and global office coordination.",
}

export default function ContactPage() {
  return <ContactPageTemplate />
}
