//using Microsoft.EntityFrameworkCore;
//using zentro.Models;

//namespace zentro.Models
//{
//    public partial class Contract
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class ContractNote
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Customer
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class CustomerAddress
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class CustomerDocument
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class CustomerHistory
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class CustomerNote
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class CustomerNoteDocument
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Damage
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Enquiry
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class GroupPricing
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Invoice
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class InvoiceItem
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class InvoiceNote
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class MotHistory
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Ownership
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Payment
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Specification
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class ServiceHistory
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Tax
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class Vehicle
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class VehicleDocument
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class VehicleNote
//    {
//        public uint xmin { get; set; }
//    }

//    public partial class FleetContext : DbContext
//    {
//        partial void OnModelCreatingPartial(ModelBuilder modelBuilder)
//        {
//            modelBuilder.Entity<Customer>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Contract>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<ContractNote>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<CustomerAddress>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<CustomerDocument>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<CustomerHistory>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<CustomerNote>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<CustomerNoteDocument>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Damage>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Enquiry>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<GroupPricing>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Invoice>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<InvoiceItem>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<InvoiceNote>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<MotHistory>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Ownership>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Payment>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<ServiceHistory>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Specification>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Tax>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<Vehicle>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<VehicleDocument>().UseXminAsConcurrencyToken();
//            modelBuilder.Entity<VehicleNote>().UseXminAsConcurrencyToken();
//        }
//    }
//}