/**
 * Tests the cursor-pagination hook and the `?fields=` helper.
 * Serves: plan §13 C4 (lean lists), plan §7.3 P00. Called by: Vitest (`npm test`).
 */
import { QueryClientProvider } from '@tanstack/react-query';
import { act, renderHook, waitFor } from '@testing-library/react';
import type { ReactNode } from 'react';
import { describe, expect, it, vi } from 'vitest';
import { createQueryClient } from '../queryClient';
import { fieldsParam, useCursorList, type CursorPage, type PageRequest } from './cursor';

interface Item {
  id: string;
  name: string;
}

const pages: Record<string, CursorPage<Item>> = {
  first: { items: [{ id: '1', name: 'a' }], next_cursor: 'c2', has_more: true },
  c2: { items: [{ id: '2', name: 'b' }], next_cursor: null, has_more: false },
};

/**
 * Wraps the hook in a fresh query client.
 * @param props Component props.
 * @param props.children The hook host.
 * @returns The provider.
 */
function Wrapper({ children }: { children: ReactNode }) {
  return <QueryClientProvider client={createQueryClient()}>{children}</QueryClientProvider>;
}

describe('useCursorList', () => {
  it('passes the cursor of the previous page and concatenates items until has_more is false', async () => {
    const fetchPage = vi.fn((request: PageRequest) =>
      Promise.resolve(pages[request.cursor ?? 'first'] as CursorPage<Item>),
    );
    const { result } = renderHook(
      () => useCursorList({ queryKey: ['items'], fetchPage, limit: 1 }),
      { wrapper: Wrapper },
    );

    await waitFor(() => {
      expect(result.current.items).toHaveLength(1);
    });
    expect(result.current.hasNextPage).toBe(true);

    await act(() => result.current.fetchNextPage());

    await waitFor(() => {
      expect(result.current.items.map((item) => item.id)).toEqual(['1', '2']);
    });
    expect(result.current.hasNextPage).toBe(false);
    expect(fetchPage.mock.calls.map(([request]) => [request.cursor, request.limit])).toEqual([
      [undefined, 1],
      ['c2', 1],
    ]);
  });
});

describe('fieldsParam', () => {
  it('joins field names and drops duplicates', () => {
    expect(fieldsParam<Item>(['id', 'name', 'id'])).toBe('id,name');
  });
});
