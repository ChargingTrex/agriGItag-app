/**
 * Lean-list helpers: cursor pagination over `Page[T]` and the `?fields=` parameter.
 * Serves: plan §13 C4 (lean lists for weak networks), docs/api/conventions.md "Lists: cursor pagination and
 * `?fields=`"; plan §7.3 P00. Called by: list screens from P01 onwards (Members, Flags, Ready lots, Batches).
 */
import { useInfiniteQuery, type QueryKey } from '@tanstack/react-query';
import { useMemo } from 'react';

/** Default page size; screens may pass their own `limit`. */
export const DEFAULT_PAGE_SIZE = 50;

/** One page of a list endpoint, exactly the API's `Page[T]` (conventions.md). */
export interface CursorPage<T> {
  /** Items of this page. */
  items: T[];
  /** Opaque cursor for the next page; null or absent on the last page. */
  next_cursor?: string | null;
  /** Whether another page exists. */
  has_more: boolean;
}

/** What `useCursorList` passes to `fetchPage`. */
export interface PageRequest {
  /** Cursor from the previous page; undefined for the first page. */
  cursor: string | undefined;
  /** Page size to send as `?limit=`. */
  limit: number;
  /** Abort signal from TanStack Query (cancelled when the screen unmounts or the key changes). */
  signal: AbortSignal;
}

/**
 * Builds the `?fields=` value from item field names, so each screen asks only for the columns it shows.
 * @param fields Field names of the list item type; duplicates are dropped, order is kept.
 * @returns A comma-separated list, e.g. `id,name,village`.
 */
// eslint-disable-next-line @typescript-eslint/no-unnecessary-type-parameters -- callers name the item type so a typo in a field name fails to compile
export function fieldsParam<T>(fields: readonly (keyof T & string)[]): string {
  return [...new Set(fields)].join(',');
}

/**
 * Infinite cursor-paginated list. Pages are fetched on demand with `fetchNextPage()`; `items` is the
 * concatenation of all fetched pages.
 * @param options Hook options.
 * @param options.queryKey Cache key for the list; include filters and the `fields` value in it.
 * @param options.fetchPage Fetches one page, typically `unwrap(api.GET(path, { params: { query: {cursor, limit,
 *   fields} }, signal }))`.
 * @param options.limit Page size, default `DEFAULT_PAGE_SIZE`.
 * @returns TanStack's infinite-query result plus `items`. Errors from `fetchPage` surface as `error`.
 */
export function useCursorList<T>(options: {
  queryKey: QueryKey;
  fetchPage: (request: PageRequest) => Promise<CursorPage<T>>;
  limit?: number;
}) {
  const { queryKey, fetchPage, limit = DEFAULT_PAGE_SIZE } = options;
  const query = useInfiniteQuery({
    queryKey: [...queryKey, { limit }],
    queryFn: ({ pageParam, signal }) => fetchPage({ cursor: pageParam, limit, signal }),
    initialPageParam: undefined as string | undefined,
    getNextPageParam: (last) => (last.has_more ? (last.next_cursor ?? undefined) : undefined),
  });
  const items = useMemo(() => query.data?.pages.flatMap((page) => page.items) ?? [], [query.data]);
  return { ...query, items };
}
