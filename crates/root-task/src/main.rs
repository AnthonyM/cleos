#![no_std]
#![no_main]

use sel4_root_task::{root_task, Never};

#[root_task]
fn main(_bootinfo: &sel4::BootInfoPtr) -> sel4::Result<Never> {
    sel4::debug_println!("Hello from CleOS root task!");
    sel4::init_thread::suspend_self()
}
