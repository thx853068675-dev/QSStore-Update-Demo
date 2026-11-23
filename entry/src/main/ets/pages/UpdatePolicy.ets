export const STORE_SYNC_DELAY_MS: number = 60 * 60 * 1000;

export function storeLink(value: string): string {
  const trimmed = value.trim();
  const match = /^qingqi-installer:\/\/app\/([1-9][0-9]*)(?:\?preview=0)?$/.exec(trimmed);
  return match && Number.isSafeInteger(Number(match[1])) ?
    'qingqi-installer://app/' + match[1] + '?preview=0' : '';
}

// This Demo publishes vMAJOR.MINOR.PATCH tags with the matching numeric
// versionCode. Other apps can retain their own version check implementation.
export function demoVersionCode(tag: string): number {
  const parts = /^v([1-9][0-9]{0,3})\.([0-9]{1,2})\.([0-9]{1,2})$/.exec(tag);
  if (!parts) return 0;
  return Number(parts[1]) * 10000 + Number(parts[2]) * 100 + Number(parts[3]);
}

export function eligibleForPrompt(local: number, latest: number, published: number, now: number): boolean {
  return local > 0 && latest > local && Number.isFinite(published) && published > 0 &&
    now - published >= STORE_SYNC_DELAY_MS;
}
