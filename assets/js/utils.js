export function getParameterByName(name) {
  const url = window.location.href;
  const cleanedName = name.replace(/[\[\]]/g, "\\$&");
  const regex = new RegExp("[?&]" + cleanedName + "(=([^&#]*)|&|#|$)")
  const results = regex.exec(url)

  let ret = null

  if (!results || !results[2]) {
    ret = ''
  } else {
    ret = decodeURIComponent(results[2].replace(/\+/g, " "))
  }

  return ret
}

export function discountId() {
  return getParameterByName('id')
}

export function ordinalIndicator(num) {
  const numStr = num.toString()
  let ordinalIndicator = null

  if (endsWith(numStr, '1')) {
    ordinalIndicator = 'st'
  } else if (endsWith(numStr, '2')) {
    ordinalIndicator = 'nd'
  } else if (endsWith(numStr, '3')) {
    ordinalIndicator = 'rd'
  } else {
    ordinalIndicator = 'th'
  }

  return ordinalIndicator
}

export function shop() {
  return document.getElementById("shop").value
}

export function title() {
  return document.getElementById("title").value
}

export function token() {
  return document.getElementById("token").value
}

export function usageLimit() {
  const usageLimit = document.getElementById("usage_limit").value
  if (usageLimit === '') return null
  return parseInt(usageLimit)
}
