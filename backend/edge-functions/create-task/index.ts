// LearnLynk Tech Test - Task 3: Edge Function create-task

// Deno + Supabase Edge Functions style
// Docs reference: https://supabase.com/docs/guides/functions

import { serve } from "https://deno.land/std@0.168.0/http/server.ts";
import { createClient } from "https://esm.sh/@supabase/supabase-js@2";

const SUPABASE_URL = Deno.env.get("SUPABASE_URL")!;
const SUPABASE_SERVICE_ROLE_KEY = Deno.env.get("SUPABASE_SERVICE_ROLE_KEY")!;

const supabase = createClient(SUPABASE_URL, SUPABASE_SERVICE_ROLE_KEY);

type CreateTaskPayload = {
  application_id: string;
  task_type: string;
  due_at: string;
};

const VALID_TYPES = ["call", "email", "review"];

serve(async (req: Request) => {
  if (req.method !== "POST") {
    return new Response(JSON.stringify({ error: "Method not allowed" }), {
      status: 405,
      headers: { "Content-Type": "application/json" },
    });
  }

  try {
    const body = (await req.json()) as Partial<CreateTaskPayload>;
    const { application_id, task_type, due_at } = body;

    // 1. Validation
    if (!application_id) {
      return new Response(JSON.stringify({ error: "Missing application_id" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    if (!task_type || !VALID_TYPES.includes(task_type)) {
      return new Response(
        JSON.stringify({
          error: `Invalid task_type. Must be one of: ${VALID_TYPES.join(", ")}`,
        }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    if (!due_at) {
      return new Response(
        JSON.stringify({ error: "Missing due_at timestamp" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    const dueDate = new Date(due_at);
    if (isNaN(dueDate.getTime())) {
      return new Response(
        JSON.stringify({ error: "Invalid due_at timestamp format" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    if (dueDate <= new Date()) {
      return new Response(
        JSON.stringify({ error: "due_at must be in the future" }),
        {
          status: 400,
          headers: { "Content-Type": "application/json" },
        }
      );
    }

    // 2. Fetch application to get tenant_id
    const { data: application, error: appError } = await supabase
      .from("applications")
      .select("tenant_id")
      .eq("id", application_id)
      .single();

    if (appError || !application) {
      return new Response(JSON.stringify({ error: "Application not found" }), {
        status: 400,
        headers: { "Content-Type": "application/json" },
      });
    }

    // 3. Insert Task
    const { data: insertedTask, error: insertError } = await supabase
      .from("tasks")
      .insert({
        tenant_id: application.tenant_id,
        application_id: application_id,
        type: task_type,
        due_at: due_at,
        status: "open",
      })
      .select("id")
      .single();

    if (insertError) {
      console.error("Insert Error:", insertError);
      return new Response(JSON.stringify({ error: "Failed to create task" }), {
        status: 500,
        headers: { "Content-Type": "application/json" },
      });
    }

    return new Response(
      JSON.stringify({ success: true, task_id: insertedTask.id }),
      {
        status: 200,
        headers: { "Content-Type": "application/json" },
      }
    );
  } catch (err) {
    console.error("Internal Error:", err);
    return new Response(JSON.stringify({ error: "Internal server error" }), {
      status: 500,
      headers: { "Content-Type": "application/json" },
    });
  }
});
