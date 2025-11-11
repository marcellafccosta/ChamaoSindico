export const invalidType = 'The token type does not match bearer';
export const invalidToken = 'invalid-token';

export function notFound(resource: string) {
  return `${resource}-not-found`;
}
