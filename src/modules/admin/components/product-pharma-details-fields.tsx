import {
  buildProductPharmaDetailsFormDefaults,
  type ProductPharmaDetails,
} from "@/lib/util/product-pharma"

type ProductPharmaDetailsFieldsProps = {
  details?: ProductPharmaDetails | null
}

export default function ProductPharmaDetailsFields({
  details = null,
}: ProductPharmaDetailsFieldsProps) {
  const defaults = buildProductPharmaDetailsFormDefaults(details)

  return (
    <div className="space-y-6">
      <p className="text-xs font-medium leading-relaxed text-gray-500">
        These fields power the public single product page. Leave any field empty if it
        is not available yet.
      </p>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Trade Name
          </label>
          <input
            name="pharma_trade_name"
            type="text"
            defaultValue={defaults.tradeName}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. Abamune, Ziagen"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Available Strength
          </label>
          <input
            name="pharma_available_strength"
            type="text"
            defaultValue={defaults.availableStrength}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. 300 mg, 600 mg"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Packing
          </label>
          <input
            name="pharma_packing"
            type="text"
            defaultValue={defaults.packing}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. 30 Tablets / Bottle"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Pack Insert / Leaflet
          </label>
          <select
            name="pharma_pack_insert_leaflet"
            defaultValue={defaults.packInsertLeaflet}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0 bg-white"
          >
            <option value="">Not specified</option>
            <option value="yes">Yes</option>
            <option value="no">No</option>
          </select>
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Therapeutic Use
          </label>
          <input
            name="pharma_therapeutic_use"
            type="text"
            defaultValue={defaults.therapeuticUse}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. Anti HIV Medication"
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Production Capacity
          </label>
          <input
            name="pharma_production_capacity"
            type="text"
            defaultValue={defaults.productionCapacity}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. 10 Million Tablet / Month"
          />
        </div>
      </div>

      <div>
        <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
          Brochure URL
        </label>
        <input
          name="pharma_brochure_url"
          type="url"
          defaultValue={defaults.brochureUrl}
          className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
          placeholder="https://..."
        />
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Pharmacodynamics
          </label>
          <textarea
            name="pharma_pharmacodynamics"
            rows={4}
            defaultValue={defaults.pharmacodynamics}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="Explain how the medicine works..."
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Therapeutic Class
          </label>
          <textarea
            name="pharma_therapeutic_class"
            rows={4}
            defaultValue={defaults.therapeuticClass}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder="e.g. Antiretroviral agent used in HAART protocols"
          />
        </div>
      </div>

      <div className="grid grid-cols-1 gap-4 md:grid-cols-2">
        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Product Uses
          </label>
          <textarea
            name="pharma_uses"
            rows={5}
            defaultValue={defaults.usesText}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder={"One use per line\nHIV-1 Infection Management\nPediatric HIV Treatment"}
          />
        </div>

        <div>
          <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
            Common Side Effects
          </label>
          <textarea
            name="pharma_side_effects"
            rows={5}
            defaultValue={defaults.sideEffectsText}
            className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
            placeholder={"One side effect per line\nNausea\nHeadache"}
          />
        </div>
      </div>

      <div>
        <label className="mb-1.5 block text-[10px] font-bold uppercase tracking-widest text-gray-400">
          Composition
        </label>
        <textarea
          name="pharma_composition"
          rows={5}
          defaultValue={defaults.compositionText}
          className="w-full rounded-lg border border-gray-300 px-4 py-2.5 text-sm font-medium focus:border-black focus:ring-0"
          placeholder={"Use one item per line\nAbacavir Sulphate | Active\nMagnesium Stearate | Excipient"}
        />
        <p className="mt-1.5 text-[10px] font-medium italic text-gray-400">
          Format each row as Ingredient | Role.
        </p>
      </div>
    </div>
  )
}
