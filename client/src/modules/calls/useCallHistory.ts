import { useCallback, useEffect, useRef, useState } from 'react';
import { fetchCallHistory, fetchCallDetail } from './api';
import { CallHistoryRecord, CallType } from './types';

const PAGE_SIZE = 20;

export interface CallHistoryState {
  records: CallHistoryRecord[];
  total: number;
  hasMore: boolean;
  isLoading: boolean;
  isLoadingMore: boolean;
  error: string | null;
  isDemoFallback: boolean;
  loadMore: () => void;
  retry: () => void;
}

/**
 * Loads one call_type's history. The two types are fetched independently and
 * never merged, which is what keeps the Audio and Video pages separate.
 */
export const useCallHistory = (type: CallType | null, search: string): CallHistoryState => {
  const [records, setRecords] = useState<CallHistoryRecord[]>([]);
  const [total, setTotal] = useState(0);
  const [hasMore, setHasMore] = useState(false);
  const [isLoading, setIsLoading] = useState(false);
  const [isLoadingMore, setIsLoadingMore] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isDemoFallback, setIsDemoFallback] = useState(false);
  const [page, setPage] = useState(1);

  // Debounce the search box so typing does not fire a request per keystroke.
  const [debouncedSearch, setDebouncedSearch] = useState(search);
  useEffect(() => {
    const timer = window.setTimeout(() => setDebouncedSearch(search), 250);
    return () => window.clearTimeout(timer);
  }, [search]);

  // Guards against a slow response for a previous type/search overwriting the
  // current one.
  const requestIdRef = useRef(0);

  const load = useCallback(
    async (targetPage: number, mode: 'replace' | 'append') => {
      if (!type) return;
      const requestId = ++requestIdRef.current;

      if (mode === 'replace') setIsLoading(true);
      else setIsLoadingMore(true);
      setError(null);

      try {
        const result = await fetchCallHistory({
          type,
          page: targetPage,
          limit: PAGE_SIZE,
          search: debouncedSearch,
        });

        if (requestId !== requestIdRef.current) return;

        setRecords((prev) => (mode === 'append' ? [...prev, ...result.page.calls] : result.page.calls));
        setTotal(result.page.total);
        setHasMore(result.page.has_more);
        setPage(result.page.page);
        setIsDemoFallback(result.isDemoFallback);
      } catch (err: any) {
        if (requestId !== requestIdRef.current) return;
        setRecords([]);
        setTotal(0);
        setHasMore(false);
        setError(err?.message || 'Could not load call history.');
      } finally {
        if (requestId === requestIdRef.current) {
          setIsLoading(false);
          setIsLoadingMore(false);
        }
      }
    },
    [type, debouncedSearch],
  );

  // Reload page 1 whenever the type or the search term changes.
  useEffect(() => {
    setRecords([]);
    load(1, 'replace');
  }, [load]);

  const loadMore = useCallback(() => {
    if (!hasMore || isLoading || isLoadingMore) return;
    load(page + 1, 'append');
  }, [hasMore, isLoading, isLoadingMore, page, load]);

  const retry = useCallback(() => load(1, 'replace'), [load]);

  return { records, total, hasMore, isLoading, isLoadingMore, error, isDemoFallback, loadMore, retry };
};

export interface CallDetailState {
  record: CallHistoryRecord | null;
  isLoading: boolean;
  error: string | null;
  isDemoFallback: boolean;
  retry: () => void;
}

export const useCallDetail = (callId: string | null): CallDetailState => {
  const [record, setRecord] = useState<CallHistoryRecord | null>(null);
  const [isLoading, setIsLoading] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const [isDemoFallback, setIsDemoFallback] = useState(false);
  const [nonce, setNonce] = useState(0);

  useEffect(() => {
    if (!callId) {
      setRecord(null);
      return;
    }

    let cancelled = false;
    setIsLoading(true);
    setError(null);

    fetchCallDetail(callId)
      .then((result) => {
        if (cancelled) return;
        setRecord(result.call);
        setIsDemoFallback(result.isDemoFallback);
      })
      .catch((err: any) => {
        if (cancelled) return;
        setRecord(null);
        setError(err?.message || 'Could not load this call record.');
      })
      .finally(() => {
        if (!cancelled) setIsLoading(false);
      });

    return () => {
      cancelled = true;
    };
  }, [callId, nonce]);

  return { record, isLoading, error, isDemoFallback, retry: () => setNonce((n) => n + 1) };
};