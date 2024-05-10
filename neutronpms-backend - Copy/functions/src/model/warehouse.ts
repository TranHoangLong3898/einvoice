// if realse product remove | null in this interface, for test case
interface WareHouse {
    id: string;
    name: string;
    isActived: boolean;
    items: { idItem: string, num: number }[],
    permission: {
        import: string[],
        export: string[]
    } | null
}

