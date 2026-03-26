type MaterialSymbolIconProps = {
  name: string
  className?: string
  filled?: boolean
}

const FILLED_SETTINGS = '"FILL" 1, "wght" 400, "GRAD" 0, "opsz" 24'
const OUTLINED_SETTINGS = '"FILL" 0, "wght" 400, "GRAD" 0, "opsz" 24'

export function MaterialSymbolIcon(props: MaterialSymbolIconProps) {
  const className = props.className
    ? `material-symbols-outlined ${props.className}`
    : "material-symbols-outlined"

  return (
    <span
      aria-hidden="true"
      className={className}
      style={{
        fontVariationSettings: props.filled ? FILLED_SETTINGS : OUTLINED_SETTINGS,
      }}
    >
      {props.name}
    </span>
  )
}
