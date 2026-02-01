import { createClient, SupabaseClient } from '@supabase/supabase-js';
import config from '../config';
import logger from '../utils/logger';

let supabaseClient: SupabaseClient | null = null;

export function getSupabaseClient(): SupabaseClient {
  if (!supabaseClient) {
    if (!config.supabase.url || !config.supabase.serviceRoleKey) {
      logger.error('Supabase credentials not configured');
      throw new Error('Supabase credentials not configured');
    }

    supabaseClient = createClient(
      config.supabase.url,
      config.supabase.serviceRoleKey,
      {
        auth: {
          autoRefreshToken: false,
          persistSession: false,
        },
      }
    );

    logger.info('Supabase client initialized');
  }

  return supabaseClient;
}

export default getSupabaseClient;
