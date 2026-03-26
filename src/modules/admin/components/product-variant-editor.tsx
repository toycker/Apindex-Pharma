"use client"

import { useEffect, useState, useTransition } from "react"
import { useRouter } from "next/navigation"
import { PlusIcon, Sparkles, ChevronDown, TrashIcon } from "lucide-react"

import { deleteVariant, saveProductVariants } from "@/lib/data/admin"
import { ProductVariant, VariantFormData } from "@/lib/supabase/types"
import { COLOR_SWATCH_MAP, STANDARD_COLORS } from "@/lib/constants/colors"
import { cn } from "@/lib/util/cn"
import { useToast } from "@modules/common/context/toast-context"
import AdminCard from "./admin-card"
import VariantMediaPicker from "./variant-media-picker"

type ProductVariantEditorProps = {
  productId: string
  initialVariants: ProductVariant[]
  productImages?: string[]
}

type OptionDefinition = {
  title: string
  values: string[]
}

function mapVariantToFormData(variant: ProductVariant): VariantFormData {
  return {
    id: variant.id,
    title: variant.title,
    sku: variant.sku || "",
    price: variant.price,
    compare_at_price: variant.compare_at_price || null,
    inventory_quantity: variant.inventory_quantity,
    image_url: variant.image_url || null,
  }
}

function createEmptyVariant(): VariantFormData {
  return {
    title: "",
    sku: "",
    price: 0,
    compare_at_price: null,
    inventory_quantity: 0,
    image_url: null,
  }
}

function normalizeOptionValues(values: string[]): string[] {
  return Array.from(
    new Set(
      values
        .map((value) => value.trim())
        .filter(Boolean)
        .map((value) => value.toUpperCase())
    )
  )
}

function buildVariantCombinations(options: OptionDefinition[]): string[][] {
  return options.reduce<string[][]>(
    (combinations, option) =>
      combinations.flatMap((combination) =>
        option.values.map((value) => [...combination, value])
      ),
    [[]]
  )
}

export default function ProductVariantEditor({
  productId,
  initialVariants,
  productImages = [],
}: ProductVariantEditorProps) {
  const router = useRouter()
  const { showToast } = useToast()
  const [isPending, startTransition] = useTransition()
  const [variants, setVariants] = useState<VariantFormData[]>(
    initialVariants.map(mapVariantToFormData)
  )
  const [options, setOptions] = useState<OptionDefinition[]>([
    { title: "Pack", values: [] },
  ])
  const [openPickerIndex, setOpenPickerIndex] = useState<number | null>(null)

  useEffect(() => {
    setVariants(initialVariants.map(mapVariantToFormData))
  }, [initialVariants])

  const handleAddVariant = () => {
    setVariants((currentVariants) => [...currentVariants, createEmptyVariant()])
  }

  const handleRemoveVariant = async (index: number, id?: string) => {
    if (!confirm("Are you sure you want to delete this variant?")) {
      return
    }

    if (id) {
      startTransition(async () => {
        try {
          await deleteVariant(id)
          setVariants((currentVariants) =>
            currentVariants.filter((_, currentIndex) => currentIndex !== index)
          )
          router.refresh()
        } catch (error) {
          console.error(error)
          showToast("Failed to delete the variant. Please try again.", "error", "Delete Failed")
        }
      })
      return
    }

    setVariants((currentVariants) =>
      currentVariants.filter((_, currentIndex) => currentIndex !== index)
    )
  }

  const handleChange = (
    index: number,
    field: keyof VariantFormData,
    value: VariantFormData[keyof VariantFormData]
  ) => {
    setVariants((currentVariants) => {
      const nextVariants = [...currentVariants]
      nextVariants[index] = { ...nextVariants[index], [field]: value }
      return nextVariants
    })
  }

  const handleSave = () => {
    startTransition(async () => {
      try {
        const skus = variants.map((variant) => variant.sku.trim()).filter(Boolean)
        const uniqueSkus = new Set(skus)

        if (skus.length !== uniqueSkus.size) {
          showToast("Multiple variants cannot have the same SKU.", "error", "Duplicate SKUs")
          return
        }

        await saveProductVariants(productId, variants)
        showToast("Product variants updated successfully.", "success", "Changes Saved")
        router.refresh()
      } catch (error) {
        console.error(error)
        showToast("Failed to save changes. Please try again.", "error", "Save Failed")
      }
    })
  }

  const handleUpdateOption = (
    index: number,
    field: keyof OptionDefinition,
    value: OptionDefinition[keyof OptionDefinition]
  ) => {
    setOptions((currentOptions) => {
      const nextOptions = [...currentOptions]

      if (field === "values" && Array.isArray(value)) {
        nextOptions[index] = {
          ...nextOptions[index],
          values: normalizeOptionValues(value),
        }
        return nextOptions
      }

      nextOptions[index] = {
        ...nextOptions[index],
        [field]: value,
      }
      return nextOptions
    })
  }

  const handleRemoveOption = (index: number) => {
    if (options.length <= 1) {
      return
    }

    setOptions((currentOptions) =>
      currentOptions.filter((_, currentIndex) => currentIndex !== index)
    )
  }

  const handleGenerate = () => {
    const validOptions = options.filter(
      (option) => option.title.trim() && option.values.length > 0
    )

    if (validOptions.length === 0) {
      return
    }

    const combinations = buildVariantCombinations(validOptions)
    const nextVariants: VariantFormData[] = combinations.map((combination) => {
      const title = combination.join(" / ")
      const existingVariant = variants.find((variant) => variant.title === title)

      return existingVariant || {
        ...createEmptyVariant(),
        title,
      }
    })

    setVariants(nextVariants)
    showToast(
      `Generated ${nextVariants.length} variants based on your options.`,
      "success",
      "Generation Complete"
    )
  }

  const handleBulkStock = () => {
    const quantity = prompt("Enter stock quantity for all variants:")
    if (quantity === null) {
      return
    }

    const parsedQuantity = parseInt(quantity, 10)
    if (Number.isNaN(parsedQuantity)) {
      return
    }

    setVariants((currentVariants) =>
      currentVariants.map((variant) => ({
        ...variant,
        inventory_quantity: parsedQuantity,
      }))
    )
  }

  return (
    <AdminCard title={`Product Variants (${variants.length})`}>
      <div className="space-y-6">
        <div className="p-4 border border-gray-200 rounded-xl space-y-4">
          <div className="flex items-center justify-between">
            <div className="flex items-center gap-2">
              <Sparkles className="h-4 w-4 text-purple-500" />
              <h3 className="text-xs font-black text-gray-700 uppercase tracking-widest">
                Variant Generator
              </h3>
            </div>
            <button
              type="button"
              onClick={() => setOptions((currentOptions) => [...currentOptions, { title: "", values: [] }])}
              className="text-[10px] font-bold text-blue-600 hover:underline"
            >
              + Add another option
            </button>
          </div>

          <div className="space-y-3">
            {options.map((option, index) => (
              <div key={`${option.title}-${index + 1}`} className="flex flex-col md:flex-row items-start md:items-center gap-3">
                <div className="w-full md:w-1/3">
                  <input
                    type="text"
                    placeholder="Option Title (e.g. Strength)"
                    value={option.title}
                    onChange={(event) => handleUpdateOption(index, "title", event.target.value)}
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-medium focus:border-black focus:ring-0 transition-all bg-gray-50/30"
                  />
                </div>
                <div className="flex-1 w-full relative group/val">
                  <input
                    type="text"
                    placeholder="Values (comma separated: 250 mg, 500 mg)"
                    value={option.values.join(", ")}
                    onChange={(event) =>
                      handleUpdateOption(
                        index,
                        "values",
                        event.target.value.split(",")
                      )
                    }
                    className="w-full rounded-lg border border-gray-300 px-4 py-3 text-sm font-medium focus:border-black focus:ring-0 transition-all bg-gray-50/30"
                  />
                  {option.title.toLowerCase().includes("color") ? (
                    <div className="absolute right-2 top-1/2 -translate-y-1/2 flex items-center gap-1">
                      <button
                        type="button"
                        onClick={() => setOpenPickerIndex(openPickerIndex === index ? null : index)}
                        className="p-1 hover:bg-gray-100 rounded transition-all text-gray-400 hover:text-black opacity-0 group-hover/val:opacity-100"
                        title="Pick standard colors"
                      >
                        <ChevronDown
                          className={cn(
                            "h-4 w-4 transition-transform",
                            openPickerIndex === index && "rotate-180 text-black"
                          )}
                        />
                      </button>
                    </div>
                  ) : null}

                  {openPickerIndex === index ? (
                    <>
                      <div className="fixed inset-0 z-10" onClick={() => setOpenPickerIndex(null)} />
                      <div className="absolute top-full right-0 mt-1 z-20 pt-1 animate-in fade-in zoom-in-95 duration-100">
                        <div className="bg-white border border-gray-200 rounded-xl shadow-xl p-2 min-w-[220px]">
                          <div className="p-2 border-b border-gray-50 mb-1 flex justify-between items-center">
                            <p className="text-[10px] font-black text-gray-400 uppercase tracking-widest">
                              Expanded Library
                            </p>
                            <button
                              type="button"
                              onClick={() => setOpenPickerIndex(null)}
                              className="text-[10px] text-gray-300 hover:text-black font-bold"
                            >
                              Done
                            </button>
                          </div>
                          <div className="grid grid-cols-5 gap-1.5 p-1">
                            {STANDARD_COLORS.map((color) => {
                              const colorKey = color.toLowerCase().replace(/ /g, "")
                              const hexColor = COLOR_SWATCH_MAP[colorKey] || colorKey

                              return (
                                <button
                                  key={color}
                                  type="button"
                                  onClick={() => {
                                    if (option.values.includes(color)) {
                                      return
                                    }

                                    handleUpdateOption(index, "values", [...option.values, color])
                                  }}
                                  className="w-full aspect-square rounded-md border border-gray-100 shadow-sm flex items-center justify-center hover:scale-125 hover:z-10 transition-all duration-200"
                                  style={{ backgroundColor: hexColor }}
                                  title={color}
                                />
                              )
                            })}
                          </div>
                        </div>
                      </div>
                    </>
                  ) : null}
                </div>
                <button
                  type="button"
                  onClick={() => handleRemoveOption(index)}
                  className="p-2 border border-transparent hover:bg-red-50 hover:border-red-100 rounded-lg text-gray-400 hover:text-red-500 transition-all md:self-center"
                  title="Remove option"
                >
                  <TrashIcon className="w-4 h-4" />
                </button>
              </div>
            ))}
          </div>

          <div className="flex justify-end pt-2">
            <button
              type="button"
              onClick={handleGenerate}
              className="inline-flex items-center gap-2 px-4 py-2 bg-white border border-gray-200 text-xs font-bold rounded-lg hover:border-black transition-all shadow-sm group"
            >
              <Sparkles className="h-3 w-3 text-purple-500 group-hover:scale-110 transition-transform" />
              Generate Combinations
            </button>
          </div>
        </div>

        <div className="flex items-center justify-between gap-3 rounded-xl border border-gray-200 bg-gray-50 px-4 py-3">
          <p className="text-[10px] font-medium uppercase tracking-[0.18em] text-gray-500">
            Pricing is hidden for enquiry-only catalogue variants.
          </p>
          <button
            type="button"
            onClick={handleBulkStock}
            className="text-[10px] font-bold text-gray-400 hover:text-black uppercase tracking-widest px-3 py-1.5 border border-gray-200 rounded-md hover:border-gray-300 transition-all"
          >
            Set all stock
          </button>
        </div>

        <div className="overflow-x-auto border border-gray-200 rounded-xl">
          <table className="w-full text-sm text-left">
            <thead className="bg-[#f7f8f9] text-gray-400 font-black text-[10px] border-b border-gray-200 uppercase tracking-widest">
              <tr>
                <th className="px-4 py-4 w-[60px]">Media</th>
                <th className="px-4 py-4 min-w-[150px]">Title / Option</th>
                <th className="px-4 py-4 w-[120px]">SKU</th>
                <th className="px-4 py-4 w-[96px] text-right">Stock</th>
                <th className="px-4 py-4 w-[40px]"></th>
              </tr>
            </thead>
            <tbody className="divide-y divide-gray-200">
              {variants.map((variant, index) => (
                <tr key={variant.id ?? `${variant.title}-${index + 1}`} className="bg-white group hover:bg-gray-50/50 transition-colors">
                  <td className="p-3">
                    <VariantMediaPicker
                      images={productImages}
                      selectedImage={variant.image_url || null}
                      onSelect={(url) => handleChange(index, "image_url", url)}
                    />
                  </td>
                  <td className="p-3">
                    <input
                      type="text"
                      className="w-full bg-transparent border-none rounded-md text-sm font-semibold focus:ring-0 placeholder:text-gray-300"
                      placeholder="e.g. 10 x 10 Blister"
                      value={variant.title}
                      onChange={(event) => handleChange(index, "title", event.target.value)}
                    />
                  </td>
                  <td className="p-3">
                    <input
                      type="text"
                      className="w-full bg-transparent border-none rounded-md text-[11px] font-mono font-medium focus:ring-0 placeholder:text-gray-300 uppercase"
                      placeholder="SKU-123"
                      value={variant.sku}
                      onChange={(event) => handleChange(index, "sku", event.target.value)}
                    />
                  </td>
                  <td className="p-3">
                    <input
                      type="number"
                      className={cn(
                        "w-full bg-transparent border-none rounded-md text-sm font-bold text-right focus:ring-0",
                        variant.inventory_quantity === 0 ? "text-red-500" : "text-gray-900"
                      )}
                      placeholder="0"
                      value={variant.inventory_quantity}
                      onChange={(event) =>
                        handleChange(
                          index,
                          "inventory_quantity",
                          event.target.value === "" ? 0 : parseInt(event.target.value, 10)
                        )
                      }
                    />
                  </td>
                  <td className="p-3 text-center">
                    <button
                      type="button"
                      onClick={() => handleRemoveVariant(index, variant.id)}
                      className="text-gray-300 hover:text-red-500 transition-colors p-1.5"
                      disabled={isPending}
                    >
                      <TrashIcon className="h-4 w-4" />
                    </button>
                  </td>
                </tr>
              ))}
              {variants.length === 0 ? (
                <tr>
                  <td colSpan={5} className="p-12 text-center text-gray-300 italic">
                    No variants defined. Use the generator above or add manually.
                  </td>
                </tr>
              ) : null}
            </tbody>
          </table>
        </div>

        <div className="flex justify-between items-center pt-2">
          <button
            type="button"
            onClick={handleAddVariant}
            className="flex items-center gap-2 text-xs font-black text-gray-400 hover:text-black uppercase tracking-widest transition-colors"
          >
            <PlusIcon className="h-3.5 w-3.5" />
            Add Manually
          </button>

          <button
            type="button"
            onClick={handleSave}
            disabled={isPending}
            className="px-6 py-2.5 bg-black text-white text-xs font-black rounded-xl hover:bg-gray-800 transition-all shadow-xl shadow-black/10 active:scale-95 disabled:opacity-50 uppercase tracking-widest"
          >
            {isPending ? "Syncing..." : "Save Variants"}
          </button>
        </div>
      </div>
    </AdminCard>
  )
}
